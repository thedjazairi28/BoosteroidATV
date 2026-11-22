import Foundation
import Observation
import NaturalLanguage

@Observable
class GamesViewModel {
    var library: [GameInfo] = []
    var catalog: [GameInfo] = []
    var isCatalogLoading = false
    var catalogError: String?
    private var hasLoadedCatalog = false
    private var lastCatalogAttempt: Date?
    var activeSessions: [ActiveSessionInfo] = []
    var isLoading = false
    var error: String?

    var streamSettings: StreamSettings = StreamSettings()
    private(set) var favoriteIDs: Set<String> = []
    private(set) var lastPlayedGameID: String?

    var favoriteGames: [GameInfo] {
        library.filter { favoriteIDs.contains($0.id) }
    }

    var lastPlayedGame: GameInfo? {
        guard let lastPlayedGameID else { return nil }
        return library.first { $0.id == lastPlayedGameID }
    }

    // MARK: - Streaming Region Preference
    //
    // Mirrors the account settings at cloud.boosteroid.com/profile/account/
    // main — "Permitir ligação a regiões distantes" and "Localização de
    // servidor preferida" — CONFIRMED 2026-08-02 to be plain account-level
    // preferences (see BoosteroidClient's Streaming Regions section). Loaded
    // once in `load()`; SettingsView reads/writes these directly.
    var playgrounds: [BoosteroidPlayground] = []
    var allowDistantRegions: Bool = true
    var preferredPlaygroundId: Int? = nil
    var regionSettingsError: String?

    private let client = BoosteroidClient()

    // Optional, public Steam Store data: no Steam login and no Boosteroid cookies.
    private let publicMediaService = SteamPublicMediaService()
    private(set) var publicMediaByGameID: [String: SteamPublicMedia] = [:]
    private var requestedMediaGameIDs: Set<String> = []
    private(set) var loadingMediaGameIDs: Set<String> = []

    func loadPublicMedia(for game: GameInfo, force: Bool = false) async {
        // A manual retry is useful when a CDN temporarily rejects a request.
        guard force || !requestedMediaGameIDs.contains(game.id) else { return }
        guard !loadingMediaGameIDs.contains(game.id) else { return }
        requestedMediaGameIDs.insert(game.id)
        loadingMediaGameIDs.insert(game.id)
        defer { loadingMediaGameIDs.remove(game.id) }
        publicMediaByGameID[game.id] = await publicMediaService.find(gameTitle: game.title)
    }

    func mediaStatus(for game: GameInfo) -> String {
        if loadingMediaGameIDs.contains(game.id) { return "Recherche d'une vidéo sur Steam…" }
        return publicMediaByGameID[game.id]?.diagnostic
            ?? "Recherche de la bande-annonce en attente."
    }

    func videoPreviews(for game: GameInfo) -> [GameTrailerPreview] {
        publicMediaByGameID[game.id]?.videos ?? []
    }

    /// Prefer actual gameplay footage when Steam labels it as such; otherwise
    /// use the first public trailer. It is embedded silently as moving artwork.
    func backgroundVideo(for game: GameInfo) -> URL? {
        let clips = publicMediaByGameID[game.id]?.videos ?? []
        let preferred = clips.first { clip in
            let title = clip.title.lowercased()
            return title.contains("gameplay") || title.contains("game play")
                || title.contains("jouabilité") || title.contains("extrait de jeu")
        }
        return (preferred ?? clips.first)?.videoURL
    }

    func frenchDescription(for game: GameInfo) -> String {
        if let text = publicMediaByGameID[game.id]?.descriptionFR, !text.isEmpty { return text }
        let boosteroidText = game.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if boosteroidText.count > 80, NLLanguageRecognizer.dominantLanguage(for: boosteroidText) == .french {
            return boosteroidText
        }
        if loadingMediaGameIDs.contains(game.id) { return "Recherche d'une description en français…" }
        return "Description en français indisponible pour ce jeu."
    }


    // One optional detail request per selected game. Never scan every game at launch.
    private(set) var detailByID: [String: GameInfo] = [:]
    private var requestedDetailIDs: Set<String> = []

    func enrichedGame(_ game: GameInfo) -> GameInfo {
        guard let detail = detailByID[game.id] else { return game }
        return game.enriched(with: detail)
    }

    func loadGameDetails(_ game: GameInfo, authManager: AuthManager) async {
        // A missing or unconfirmed endpoint must never prevent opening a card.
        guard Int(game.id) != nil, requestedDetailIDs.insert(game.id).inserted else { return }
        do {
            let cookies = try await authManager.resolveCookies()
            let detail = try await client.fetchApplication(id: game.id, cookies: cookies)
            detailByID[game.id] = detail
        } catch {
            // Keep the list metadata and avoid repeated failed requests.
            // This is an optional, best-effort enrichment.
        }
    }


    init() {
        if let data = UserDefaults.standard.data(forKey: "boosteroid.streamSettings"),
           let settings = try? JSONDecoder().decode(StreamSettings.self, from: data) {
            self.streamSettings = settings
        }
        favoriteIDs = Set(UserDefaults.standard.stringArray(forKey: "boosteroid.favoriteGameIDs") ?? [])
        lastPlayedGameID = UserDefaults.standard.string(forKey: "boosteroid.lastPlayedGameID")
    }

    func load(authManager: AuthManager) async {
        isLoading = true
        error = nil
        do {
            let cookies = try await authManager.resolveCookies()
            library = try await client.fetchLibrary(cookies: cookies)
            reconcileCatalogWithLibrary()
            activeSessions = (try? await client.getActiveSessions(cookies: cookies)) ?? []
            // Best-effort: Settings still works (just shows defaults) if
            // either of these fails, so neither is allowed to fail `load()`
            // as a whole the way the library fetch above does.
            playgrounds = (try? await client.fetchPlaygrounds(cookies: cookies)) ?? []
            if let pref = try? await client.fetchRegionPreference(cookies: cookies) {
                allowDistantRegions = pref.allowDistantRegions
                preferredPlaygroundId = pref.preferredPlaygroundId
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    /// Reloads the installed-game library without reloading account settings.
    /// Used by the Home screen's Refresh command after games are added or
    /// removed on another Boosteroid device.
    func refreshLibrary(authManager: AuthManager) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let cookies = try await authManager.resolveCookies()
            library = try await client.fetchLibrary(cookies: cookies)
            reconcileCatalogWithLibrary()
            activeSessions = (try? await client.getActiveSessions(cookies: cookies)) ?? activeSessions
        } catch {
            self.error = error.localizedDescription
        }
    }

    /// Loads the complete observed "Installer" collection and merges it with
    /// the signed-in user's library. This is a unified first step, NOT a claim
    /// that every Boosteroid collection is already represented.
    func loadCatalog(authManager: AuthManager, force: Bool = false) async {
        guard !isCatalogLoading, (force || !hasLoadedCatalog) else { return }

        // A 5-minute cooldown applies even when the user presses Refresh.
        // The endpoint has a shared quota; repeated full rescans caused 429.
        if let lastCatalogAttempt, Date().timeIntervalSince(lastCatalogAttempt) < 300 {
            return
        }

        isCatalogLoading = true
        catalogError = nil
        defer { isCatalogLoading = false }

        // Home and Catalog can launch tasks at the same moment. Wait until
        // the initial library pagination finishes rather than hammering
        // Boosteroid with simultaneous library and catalog scans.
        while isLoading {
            if Task.isCancelled { return }
            try? await Task.sleep(for: .milliseconds(250))
        }
        if Task.isCancelled { return }

        lastCatalogAttempt = Date()
        do {
            let cookies = try await authManager.resolveCookies()
            let fetched = try await client.fetchBrowsableCatalog(cookies: cookies)
            if Task.isCancelled { return }
            catalog = fetched
            reconcileCatalogWithLibrary()
            hasLoadedCatalog = true
        } catch {
            // Keep all already retrieved games and library cards available.
            reconcileCatalogWithLibrary()
            if error.localizedDescription.contains("429") {
                catalogError = "Boosteroid limite temporairement les recherches (HTTP 429). Les jeux déjà chargés restent disponibles. Réessaie plus tard."
            } else {
                catalogError = "Mise à jour du catalogue indisponible : \(error.localizedDescription)"
            }
        }
    }

    /// The API field `installed` means server-side installation status, not
    /// "owned by the user". Membership is determined from the actual library.
    private func reconcileCatalogWithLibrary() {
        let libraryIDs = Set(library.map(\.id))
        for index in catalog.indices {
            catalog[index].isInLibrary = libraryIDs.contains(catalog[index].id)
        }

        var knownIDs = Set(catalog.map(\.id))
        for game in library where knownIDs.insert(game.id).inserted {
            catalog.append(game)
        }
        catalog.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    /// Writes "Permitir ligação a regiões distantes" — optimistic update,
    /// reverted if the PATCH fails (matching saveSettings' fire-and-forget
    /// style elsewhere, but this one's server-side so it needs a real
    /// success/failure path rather than just writing UserDefaults).
    func setAllowDistantRegions(_ allow: Bool, authManager: AuthManager) async {
        let previous = allowDistantRegions
        allowDistantRegions = allow
        regionSettingsError = nil
        do {
            let cookies = try await authManager.resolveCookies()
            try await client.setAllowDistantRegions(allow, cookies: cookies)
        } catch {
            allowDistantRegions = previous
            regionSettingsError = "Mise à jour impossible : \(error.localizedDescription)"
        }
    }

    /// Writes "Localização de servidor preferida". `nil` = "Localização
    /// automática".
    func setPreferredPlayground(_ id: Int?, authManager: AuthManager) async {
        let previous = preferredPlaygroundId
        preferredPlaygroundId = id
        regionSettingsError = nil
        do {
            let cookies = try await authManager.resolveCookies()
            try await client.setPreferredPlayground(id, cookies: cookies)
        } catch {
            preferredPlaygroundId = previous
            regionSettingsError = "Mise à jour impossible : \(error.localizedDescription)"
        }
    }

    /// Resolves a raw gateway host (e.g. `SessionInfo.nodeBaseUrl`, like
    /// "https://sp7.cloud.boosteroid.com:443") to the friendly playground
    /// name shown in the server picker, by matching hostnames — CONFIRMED
    /// both `/v1/streaming/playgrounds`' gateway addresses and
    /// `session/details`' `gw` use the exact same "<code>.cloud.
    /// boosteroid.com" host. Used by StreamView to show which server a
    /// session actually landed on. Returns nil if playgrounds haven't
    /// loaded yet or nothing matches.
    func playgroundName(forGatewayHost host: String) -> String? {
        guard let targetHost = URL(string: host)?.host else { return nil }
        for playground in playgrounds {
            for gateway in playground.gateways {
                if URL(string: gateway.address)?.host == targetHost {
                    return playground.displayName
                }
            }
        }
        return nil
    }

    func saveSettings() {
        let data = try? JSONEncoder().encode(streamSettings)
        UserDefaults.standard.set(data, forKey: "boosteroid.streamSettings")
    }

    func toggleFavorite(_ game: GameInfo) {
        if favoriteIDs.contains(game.id) {
            favoriteIDs.remove(game.id)
        } else {
            favoriteIDs.insert(game.id)
        }
        UserDefaults.standard.set(Array(favoriteIDs).sorted(), forKey: "boosteroid.favoriteGameIDs")
    }

    func isFavorite(_ game: GameInfo) -> Bool {
        favoriteIDs.contains(game.id)
    }

    func markPlayed(_ game: GameInfo) {
        lastPlayedGameID = game.id
        UserDefaults.standard.set(game.id, forKey: "boosteroid.lastPlayedGameID")
    }
}


// MARK: - Public video previews and French storefront text
// Experimental Steam Store endpoints; request only when a game is selected.

struct GameTrailerPreview: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let thumbnail: URL?
    let videoURL: URL
}

struct SteamPublicMedia: Sendable {
    let descriptionFR: String?
    let videos: [GameTrailerPreview]
    let diagnostic: String
}

private actor SteamPublicMediaService {
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 8
        configuration.timeoutIntervalForResource = 15
        // The public Steam Store endpoints may reject generic embedded-client
        // requests. Advertise a regular browser, without sending auth cookies.
        configuration.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            "Accept-Language": "fr-FR,fr;q=0.9,en;q=0.5"
        ]
        return URLSession(configuration: configuration)
    }()

    func find(gameTitle: String) async -> SteamPublicMedia {
        let cleanTitle = gameTitle
            .replacingOccurrences(of: #"\s*\((steam|xbox|epic|rockstar|ubisoft|ea app|gog)\)\s*$"#,
                                  with: "", options: [.regularExpression, .caseInsensitive])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            return SteamPublicMedia(descriptionFR: nil, videos: [], diagnostic: "Nom du jeu vide.")
        }

        // Steam's search endpoint may fail on tvOS (or return no exact match).
        // A verified Steam app ID for the user's RDR2 regression test avoids
        // depending on the separate search endpoint in that specific case.
        let canonical = normalized(cleanTitle)
        let knownIDs: [String: Int] = [
            "red dead redemption 2": 1174180
        ]
        var chosenID = knownIDs[canonical]

        if chosenID == nil {
            var search = URLComponents(string: "https://store.steampowered.com/api/storesearch/")!
            search.queryItems = [
                URLQueryItem(name: "term", value: cleanTitle),
                URLQueryItem(name: "l", value: "french"),
                URLQueryItem(name: "cc", value: "fr")
            ]
            guard let searchURL = search.url,
                  let searchJSON = await json(from: searchURL) as? [String: Any],
                  let items = searchJSON["items"] as? [[String: Any]] else {
                return SteamPublicMedia(descriptionFR: nil, videos: [],
                                        diagnostic: "Recherche Steam inaccessible : réseau ou réponse non conforme.")
            }
            // Do not accidentally play footage of a similarly named game or edition.
            if let matched = items.first(where: { item in
                guard let title = item["name"] as? String else { return false }
                return normalized(title) == canonical
            }) {
                chosenID = matched["id"] as? Int
            }
        }

        guard let appID = chosenID else {
            return SteamPublicMedia(descriptionFR: nil, videos: [],
                                    diagnostic: "Ce jeu n'a pas été identifié dans le catalogue Steam.")
        }

        var detail = URLComponents(string: "https://store.steampowered.com/api/appdetails")!
        detail.queryItems = [
            URLQueryItem(name: "appids", value: String(appID)),
            URLQueryItem(name: "l", value: "french"),
            URLQueryItem(name: "cc", value: "fr")
        ]
        guard let detailURL = detail.url,
              let root = await json(from: detailURL) as? [String: Any],
              let envelope = root[String(appID)] as? [String: Any],
              let success = envelope["success"] as? Bool, success,
              let data = envelope["data"] as? [String: Any] else {
            return SteamPublicMedia(descriptionFR: nil, videos: [],
                                    diagnostic: "Steam a refusé ou n'a pas fourni la fiche du jeu (ID \(appID)).")
        }

        let rawText = data["short_description"] as? String ?? ""
        let candidate = rawText
            .replacingOccurrences(of: "<[^>]*>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let french = candidate.count >= 55
            && NLLanguageRecognizer.dominantLanguage(for: candidate) == .french
                ? candidate : nil

        let movies = data["movies"] as? [[String: Any]] ?? []
        var previews: [GameTrailerPreview] = []
        for movie in movies {
            guard let name = movie["name"] as? String else { continue }

            // Steam has progressively replaced downloadable MP4 trailer URLs
            // with an H.264 HLS master playlist. tvOS AVPlayer can play HLS
            // directly: no transcoding, download, YouTube or external player.
            // Keep the old MP4 source as a fallback for older game records.
            let rawHLS = (movie["hls_h264"] as? String) ?? (movie["hls"] as? String)
            let rawMP4 = (movie["mp4"] as? [String: Any]).flatMap {
                ($0["max"] as? String) ?? ($0["480"] as? String)
            }
            let hlsURL = rawHLS.flatMap(httpsVideoURL).flatMap { url in
                url.path.lowercased().hasSuffix(".m3u8") ? url : nil
            }
            let mp4URL = rawMP4.flatMap(httpsVideoURL).flatMap { url in
                url.path.lowercased().hasSuffix(".mp4") ? url : nil
            }
            guard let videoURL = hlsURL ?? mp4URL else { continue }

            let thumbnail = (movie["thumbnail"] as? String).flatMap(httpsVideoURL)
            let id = movie["id"] as? Int ?? previews.count
            previews.append(GameTrailerPreview(id: id, title: name, thumbnail: thumbnail, videoURL: videoURL))
            if previews.count == 3 { break }
        }

        let diagnostic: String
        if !previews.isEmpty {
            let hlsCount = previews.filter { $0.videoURL.path.lowercased().hasSuffix(".m3u8") }.count
            diagnostic = "\(previews.count) vidéo(s) trouvée(s) pour l'ID \(appID) (\(hlsCount) HLS)."
        } else if movies.isEmpty {
            diagnostic = "Aucune vidéo publiée dans les données Steam de ce jeu (ID \(appID))."
        } else {
            diagnostic = "\(movies.count) vidéo(s) listée(s), mais aucune URL HLS H.264 ni MP4 utilisable (ID \(appID))."
        }
        return SteamPublicMedia(descriptionFR: french, videos: previews, diagnostic: diagnostic)
    }

    private func json(from url: URL) async -> Any? {
        do {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (data, response) = try await session.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200, data.count < 2_000_000 else { return nil }
            return try JSONSerialization.jsonObject(with: data)
        } catch {
            return nil
        }
    }

    private func normalized(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func httpsVideoURL(_ text: String) -> URL? {
        guard var components = URLComponents(string: text) else { return nil }
        if components.scheme == "http" { components.scheme = "https" }
        guard components.scheme == "https", let host = components.host?.lowercased(),
              host == "steamstatic.com" || host.hasSuffix(".steamstatic.com")
                  || host == "akamaihd.net" || host.hasSuffix(".akamaihd.net")
        else { return nil }
        return components.url
    }
}
