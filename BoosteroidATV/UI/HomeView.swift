import SwiftUI
import AVFoundation
import UIKit

struct HomeView: View {
    let featuredGame: GameInfo?
    let favoriteGames: [GameInfo]
    let isLoading: Bool
    let error: String?
    let onPlay: (GameInfo) -> Void
    let onShowDetails: (GameInfo) -> Void
    let onRefresh: () async -> Void

    var body: some View {
        ZStack {
            BoosteroidTheme.background.ignoresSafeArea()

            if isLoading, featuredGame == nil {
                loadingView
            } else if featuredGame == nil {
                emptyView
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 52) {
                        if let featuredGame { featuredBanner(featuredGame) }
                        favoritesShelf
                    }
                    .padding(.horizontal, 60)
                    .padding(.top, 42)
                    .padding(.bottom, 80)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func featuredBanner(_ game: GameInfo) -> some View {
        ZStack(alignment: .bottomLeading) {
            heroArtwork(for: game)
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.08), .black.opacity(0.82)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 16) {
                Text(game.title)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 5)
                    .lineLimit(1)
                Button { onPlay(game) } label: {
                    Label("Jouer", systemImage: "play.fill")
                        .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .tint(BoosteroidTheme.violet)
                Button { onShowDetails(game) } label: {
                    Label("Détails du jeu", systemImage: "info.circle")
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
            .padding(40)
        }
        .focusSection()
    }

    private var favoritesShelf: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Favoris")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            if favoriteGames.isEmpty {
                Label("Ajoute des jeux aux favoris depuis la bibliothèque pour les retrouver ici.", systemImage: "star")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 42)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 24) {
                        ForEach(favoriteGames) { game in
                            GameCard(game: game, onPlay: onPlay)
                                .frame(width: 200)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .scrollClipDisabled()
            }

            if let error {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 22) {
            ProgressView()
                .controlSize(.large)
            Text("Chargement de votre bibliothèque Boosteroid…")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("Aucun jeu pour le moment", systemImage: "gamecontroller")
        } description: {
            Text(error ?? "Ajoute un jeu dans Boosteroid, puis sélectionne Actualiser.")
        } actions: {
            Button("Actualiser") { Task { await onRefresh() } }
                .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private func heroArtwork(for game: GameInfo) -> some View {
        if let urlString = game.heroBannerUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    placeholder(for: game)
                }
            }
        } else {
            placeholder(for: game)
        }
    }

    private func placeholder(for game: GameInfo) -> some View {
        Rectangle()
            .fill(BoosteroidTheme.cardGradient)
            .overlay(Text(game.title).font(.headline).multilineTextAlignment(.center).padding())
    }
}

struct GameOverviewView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(GamesViewModel.self) private var viewModel
    let game: GameInfo
    let isFavorite: Bool
    let onPlay: () -> Void
    let onToggleFavorite: () -> Void
    let onDismiss: () -> Void

    @State private var videoPlaybackError: String?
    @State private var previewEnabled = true
    @State private var launchRequested = false
    private var shownGame: GameInfo { viewModel.enrichedGame(game) }

    /// Stop HLS playback BEFORE the full-screen streaming view is allocated.
    /// SwiftUI's cover transition alone may briefly keep the trailer decoder alive.
    private func prepareToLaunch() {
        guard !launchRequested else { return }
        launchRequested = true
        previewEnabled = false
        Task { @MainActor in
            // One render pass gives dismantleUIView a chance to tear down AVPlayer
            // before WebRTC allocates its own video decoder.
            try? await Task.sleep(for: .milliseconds(180))
            onPlay()
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.96).ignoresSafeArea()

            ZStack(alignment: .bottomLeading) {
                ZStack {
                    heroArtwork
                    if previewEnabled, let videoURL = viewModel.backgroundVideo(for: game) {
                        SilentGameVideoBackground(url: videoURL, onError: { videoPlaybackError = $0 })
                            .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay {
                    // Keep the details legible on the left while gameplay moves on the right.
                    LinearGradient(
                        colors: [.black.opacity(0.93), .black.opacity(0.73), .black.opacity(0.24)],
                        startPoint: .leading, endPoint: .trailing
                    )
                }
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.38)],
                        startPoint: .top, endPoint: .bottom
                    )
                }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(shownGame.title)
                            .font(.system(size: 54, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(radius: 6)
                            .lineLimit(2)

                        Label(
                            shownGame.isInLibrary ? "Dans ma bibliothèque"
                                : (shownGame.requiresInstallation ? "Installation nécessaire" : "Prêt à jouer"),
                            systemImage: shownGame.requiresInstallation ? "square.and.arrow.down" : "checkmark.circle.fill"
                        )
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(shownGame.requiresInstallation ? .orange : BoosteroidTheme.accent)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("À propos du jeu")
                                .font(.title2.weight(.semibold))
                            Text(viewModel.frenchDescription(for: shownGame))
                                .font(.system(size: 24))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(5)
                                .fixedSize(horizontal: false, vertical: true)
                            if !shownGame.genres.isEmpty {
                                Text("Genres : " + GameDetailsFR.genres(for: game))
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            if !shownGame.storeIdentifiers.isEmpty {
                                Text("Boutiques : " + GameDetailsFR.stores(for: game))
                                    .font(.callout)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                        }
                        .frame(maxWidth: 800, alignment: .leading)

                        // Never expose technical Steam media diagnostics on the game
                        // sheet. Only offer a retry when a completed lookup found no clip.
                        if viewModel.backgroundVideo(for: game) == nil
                            && viewModel.publicMediaByGameID[game.id] != nil
                            && !viewModel.loadingMediaGameIDs.contains(game.id) {
                            Button("Réessayer l'aperçu vidéo") {
                                Task { await viewModel.loadPublicMedia(for: game, force: true) }
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }

                        HStack(spacing: 16) {
                            Button(action: prepareToLaunch) {
                                Label(
                                    shownGame.requiresInstallation ? "Installer et jouer" : "Jouer",
                                    systemImage: shownGame.requiresInstallation ? "square.and.arrow.down" : "play.fill"
                                )
                                .frame(minWidth: 120)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(BoosteroidTheme.violet)
                            .disabled(launchRequested)

                            Button(action: onToggleFavorite) {
                                Label(isFavorite ? "Retirer des favoris" : "Ajouter aux favoris",
                                      systemImage: isFavorite ? "star.fill" : "star")
                            }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        Text("BOOSTEROID")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Text("Jeu en streaming")
                            .font(.title3)
                            .foregroundStyle(.white)
                    }
                }
                .padding(80)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.18), lineWidth: 1))
            .padding(.horizontal, 96)
            .padding(.vertical, 86)
        }
        .onExitCommand(perform: onDismiss)
        .onDisappear { previewEnabled = false }
        .task(id: game.id) {
            await viewModel.loadGameDetails(game, authManager: authManager)
        }
        .task(id: game.id) {
            await viewModel.loadPublicMedia(for: game)
        }
    }

    @ViewBuilder
    private var heroArtwork: some View {
        if let value = shownGame.heroBannerUrl, let url = URL(string: value) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    BoosteroidTheme.cardGradient
                }
            }
        } else {
            BoosteroidTheme.cardGradient
        }
    }
}


// MARK: - Automatic silent video backdrop
// Plays publicly accessible Steam H.264 HLS or legacy MP4 trailers; no YouTube login.
// AVPlayerLayer has no visible player controls and is non-interactive.

private struct SilentGameVideoBackground: UIViewRepresentable {
    let url: URL
    let onError: (String) -> Void

    func makeUIView(context: Context) -> SilentGameVideoSurface {
        let view = SilentGameVideoSurface()
        view.start(url: url, onError: onError)
        return view
    }

    func updateUIView(_ uiView: SilentGameVideoSurface, context: Context) {
        uiView.start(url: url, onError: onError)
    }

    static func dismantleUIView(_ uiView: SilentGameVideoSurface, coordinator: ()) {
        uiView.stop()
    }
}


private final class SilentGameVideoSurface: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var activeURL: URL?
    private var player: AVPlayer?
    private var looper: AVPlayerLooper?
    private var playerStatusObservation: NSKeyValueObservation?
    private var onError: ((String) -> Void)?

    private var videoLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        isUserInteractionEnabled = false
        backgroundColor = .clear
        videoLayer.videoGravity = .resizeAspectFill
        videoLayer.backgroundColor = UIColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func start(url: URL, onError: @escaping (String) -> Void) {
        self.onError = onError
        guard activeURL != url else { return }
        stop()
        self.onError = onError
        activeURL = url

        let activePlayer: AVPlayer
        if url.path.lowercased().hasSuffix(".m3u8") {
            // HLS is supported natively by AVFoundation on tvOS.
            // Avoid AVPlayerLooper on HLS: it creates redundant stream
            // requests and can cause unnecessary buffering/downloads.
            let item = AVPlayerItem(url: url)
            let hlsPlayer = AVPlayer(playerItem: item)
            hlsPlayer.actionAtItemEnd = .pause
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(replayHLS(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: item
            )
            activePlayer = hlsPlayer
        } else {
            // Legacy MP4: standard queue-based looping remains supported.
            let queue = AVQueuePlayer()
            queue.actionAtItemEnd = .none
            looper = AVPlayerLooper(player: queue, templateItem: AVPlayerItem(url: url))
            activePlayer = queue
        }

        activePlayer.isMuted = true
        activePlayer.volume = 0
        player = activePlayer
        videoLayer.player = activePlayer
        playerStatusObservation = activePlayer.observe(\.status, options: [.new]) { [weak self] observed, _ in
            guard observed.status == .failed else { return }
            let detail = observed.error?.localizedDescription ?? "Erreur de décodage ou d'accès au média."
            DispatchQueue.main.async { [weak self] in
                self?.onError?("La vidéo est trouvée mais la lecture tvOS échoue : " + detail)
            }
        }
        activePlayer.play()
    }

    @objc private func replayHLS(_ note: Notification) {
        guard let currentItem = player?.currentItem, note.object as? AVPlayerItem === currentItem,
              activeURL?.path.lowercased().hasSuffix(".m3u8") == true else { return }
        player?.seek(to: .zero) { [weak self] finished in
            if finished { self?.player?.play() }
        }
    }

    func stop() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        playerStatusObservation?.invalidate()
        playerStatusObservation = nil
        player?.pause()
        looper?.disableLooping()
        videoLayer.player = nil
        looper = nil
        player = nil
        activeURL = nil
        onError = nil
    }

    deinit {
        player?.pause()
        NotificationCenter.default.removeObserver(self)
    }
}

private enum GameDetailsFR {
    /// Preserve editorial text from Boosteroid; do not invent a synopsis when the API has none.
    static func summary(for game: GameInfo) -> String {
        let source = game.summary?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return source.isEmpty ? "Aucun résumé détaillé n'est fourni par Boosteroid pour ce jeu." : source
    }

    static func genres(for game: GameInfo) -> String {
        game.genres.prefix(6).map(genre).joined(separator: " · ")
    }

    static func stores(for game: GameInfo) -> String {
        game.storeIdentifiers.map { key in
            let value = key.lowercased()
            if value.contains("steam") { return "Steam" }
            if value.contains("xbox") || value.contains("microsoft") { return "Xbox" }
            if value.contains("epic") { return "Epic Games" }
            return key
        }.joined(separator: " · ")
    }

    static func genre(_ value: String) -> String {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "action": return "Action"
        case "adventure": return "Aventure"
        case "role-playing", "role playing", "rpg": return "Jeu de rôle"
        case "strategy": return "Stratégie"
        case "simulation": return "Simulation"
        case "racing": return "Course"
        case "sports", "sport": return "Sport"
        case "shooter", "first-person shooter", "fps": return "Jeu de tir"
        case "fighting": return "Combat"
        case "puzzle": return "Réflexion"
        case "survival": return "Survie"
        case "horror": return "Horreur"
        case "multiplayer": return "Multijoueur"
        case "indie": return "Indépendant"
        case "platformer": return "Plateforme"
        case "open world": return "Monde ouvert"
        default: return value
        }
    }
}

struct LibraryView: View {
    let games: [GameInfo]
    let isLoading: Bool
    let onPlay: (GameInfo) -> Void
    @Environment(GamesViewModel.self) private var viewModel
    @State private var searchText = ""
    @State private var sortOrder: LibrarySortOrder = .default
    @State private var carouselRequest: LibraryCarouselRequest?
    @State private var queuedGameToPlay: GameInfo?

    private var filteredGames: [GameInfo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        var result = games.filter { game in
            query.isEmpty || game.title.localizedCaseInsensitiveContains(query)
        }
        switch sortOrder {
        case .default: break
        case .titleAZ: result.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        case .titleZA: result.sort { $0.title.localizedStandardCompare($1.title) == .orderedDescending }
        case .recentFirst:
            result.sort {
                if $0.id == viewModel.lastPlayedGameID { return true }
                if $1.id == viewModel.lastPlayedGameID { return false }
                return $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        }
        return result
    }

    var body: some View {
        ZStack {
            BoosteroidTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    libraryHeader

                    if filteredGames.isEmpty, !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 140)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220, maximum: 260), spacing: 40)], spacing: 40) {
                            ForEach(filteredGames) { game in
                                GameCard(game: game) { selected in
                                    carouselRequest = LibraryCarouselRequest(games: filteredGames, startId: selected.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.vertical, 50)
            }

            if isLoading, games.isEmpty { ProgressView().controlSize(.large) }
        }
        .searchable(
            text: $searchText,
            prompt: Text(games.isEmpty ? "Chargement de la bibliothèque…" : "Rechercher parmi \(games.count) jeux")
        )
        .fullScreenCover(item: $carouselRequest, onDismiss: {
            // Dismiss the moving card (and stop its trailer) before starting streaming.
            guard let selected = queuedGameToPlay else { return }
            queuedGameToPlay = nil
            onPlay(selected)
        }) { request in
            LibraryCarouselView(
                request: request,
                onPlay: { selected in
                    queuedGameToPlay = selected
                    carouselRequest = nil
                },
                onDismiss: { carouselRequest = nil }
            )
            .environment(viewModel)
        }
    }

    private var libraryHeader: some View {
        HStack(spacing: 18) {
            Text("Bibliothèque").font(.largeTitle.weight(.bold))
            Text("\(filteredGames.count) jeux sur \(games.count)").foregroundStyle(.secondary)
            Spacer()
            Menu {
                ForEach(LibrarySortOrder.allCases, id: \.self) { order in
                    Button {
                        sortOrder = order
                    } label: {
                        Label(order.rawValue, systemImage: sortOrder == order ? "checkmark" : "circle")
                    }
                }
            } label: {
                Label("Trier : \(sortOrder.rawValue)", systemImage: "arrow.up.arrow.down")
            }
            .buttonStyle(.bordered)
            .tint(.gray)
        }
    }
}

private enum LibrarySortOrder: String, CaseIterable {
    case `default` = "Par défaut"
    case titleAZ = "A → Z"
    case titleZA = "Z → A"
    case recentFirst = "Joué récemment"
}

private struct LibraryCarouselRequest: Identifiable {
    let id = UUID()
    let games: [GameInfo]
    let startId: String
}

private struct LibraryCarouselView: View {
    @Environment(AuthManager.self) private var authManager
    private enum ActionFocus: Hashable { case play, favorite }

    let request: LibraryCarouselRequest
    let onPlay: (GameInfo) -> Void
    let onDismiss: () -> Void
    @Environment(GamesViewModel.self) private var viewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var currentIndex: Int
    @State private var navigationDirection = 1
    @State private var videoPlaybackError: String?
    @FocusState private var actionFocus: ActionFocus?

    init(request: LibraryCarouselRequest, onPlay: @escaping (GameInfo) -> Void, onDismiss: @escaping () -> Void) {
        self.request = request
        self.onPlay = onPlay
        self.onDismiss = onDismiss
        _currentIndex = State(initialValue: request.games.firstIndex { $0.id == request.startId } ?? 0)
    }

    private var game: GameInfo { viewModel.enrichedGame(request.games[currentIndex]) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.96).ignoresSafeArea()

                // Match GeForce Now's accordion geometry. GeometryReader uses
                // tvOS's inset safe area here, so the card deliberately extends
                // nearly to that frame's edges to occupy about 90% of the actual
                // television width, while retaining the neighboring previews.
                // A prior HStack clipped the artwork before assigning those
                // widths, allowing the full images to spill over each other.
                ZStack {
                    if currentIndex > 0 {
                        neighborCard(at: currentIndex - 1, alignment: .trailing)
                            .frame(width: geo.size.width * 0.11, height: geo.size.height)
                            .compositingGroup()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            // Center-card half width (49%) + preview half
                            // width (5.5%) + a visible GeForce-style gutter.
                            .offset(x: -(geo.size.width * 0.545 + 24))
                    }

                    overviewCard(game)
                        .frame(width: geo.size.width * 0.98, height: geo.size.height)
                        .compositingGroup()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        }
                        .id(game.id)
                        .transition(cardTransition)
                        .zIndex(1)

                    if currentIndex + 1 < request.games.count {
                        neighborCard(at: currentIndex + 1, alignment: .leading)
                            .frame(width: geo.size.width * 0.11, height: geo.size.height)
                            .compositingGroup()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .offset(x: geo.size.width * 0.545 + 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, geo.size.height * 0.035)
            }
        }
        .onMoveCommand { direction in
            switch (direction, actionFocus) {
            case (.right, .play):
                actionFocus = .favorite
            case (.left, .favorite):
                actionFocus = .play
            case (.left, .play), (.left, nil):
                if currentIndex > 0 { moveCard(by: -1) }
            case (.right, .favorite), (.right, nil):
                if currentIndex + 1 < request.games.count { moveCard(by: 1) }
            default:
                break
            }
        }
        .onExitCommand(perform: onDismiss)
        .defaultFocus($actionFocus, .play)
        .onChange(of: currentIndex) { _, _ in videoPlaybackError = nil }
        .task(id: request.games[currentIndex].id) {
            // Rapid navigation must not trigger dozens of requests.
            do { try await Task.sleep(for: .milliseconds(450)) }
            catch { return }
            guard !Task.isCancelled else { return }
            await viewModel.loadGameDetails(request.games[currentIndex], authManager: authManager)
        }
        .task(id: request.games[currentIndex].id) {
            do { try await Task.sleep(for: .milliseconds(450)) }
            catch { return }
            guard !Task.isCancelled else { return }
            await viewModel.loadPublicMedia(for: request.games[currentIndex])
        }
    }

    private var cardTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        let incoming: Edge = navigationDirection > 0 ? .trailing : .leading
        let outgoing: Edge = navigationDirection > 0 ? .leading : .trailing
        return .asymmetric(
            insertion: .move(edge: incoming).combined(with: .opacity),
            removal: .move(edge: outgoing).combined(with: .opacity)
        )
    }

    private func moveCard(by offset: Int) {
        let destination = currentIndex + offset
        guard request.games.indices.contains(destination) else { return }
        navigationDirection = offset
        withAnimation(reduceMotion ? nil : .interactiveSpring(response: 0.38, dampingFraction: 0.84)) {
            currentIndex = destination
        }
        actionFocus = .play
    }

    @ViewBuilder private func neighborCard(at index: Int, alignment: Alignment) -> some View {
        if request.games.indices.contains(index) {
            carouselArtwork(request.games[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        } else { Color.clear }
    }

    private func overviewCard(_ game: GameInfo) -> some View {
        ZStack {
            ZStack {
                carouselArtwork(game)
                if let videoURL = viewModel.backgroundVideo(for: game) {
                    SilentGameVideoBackground(url: videoURL, onError: { videoPlaybackError = $0 })
                        .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [.black.opacity(0.78), .black.opacity(0.54), .black.opacity(0.40)],
                    startPoint: .leading, endPoint: .trailing
                )
            }

            HStack(alignment: .center, spacing: 38) {
                posterArtwork(game)
                    .frame(width: 285, height: 405)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 15) {
                    Text("FICHE DU JEU")
                        .font(.system(size: 17, weight: .bold))
                        .tracking(2.0)
                        .foregroundStyle(BoosteroidTheme.accent)

                    Text(game.title)
                        .font(.system(size: 43, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Label("Dans ma bibliothèque", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(BoosteroidTheme.accent)

                    if !game.genres.isEmpty {
                        Text(GameDetailsFR.genres(for: game))
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.82))
                            .lineLimit(2)
                    }

                    Text("À propos du jeu")
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 10)

                    Text(viewModel.frenchDescription(for: game))
                        .font(.system(size: 21))
                        .foregroundStyle(.white.opacity(0.90))
                        .lineLimit(5)
                        .fixedSize(horizontal: false, vertical: true)

                    // Video discovery counts, Steam IDs and transport details
                    // belong in diagnostics, not the television interface.
                    if viewModel.backgroundVideo(for: game) == nil
                        && viewModel.publicMediaByGameID[game.id] != nil
                        && !viewModel.loadingMediaGameIDs.contains(game.id) {
                        Button("Réessayer la vidéo") {
                            Task { await viewModel.loadPublicMedia(for: game, force: true) }
                        }
                        .font(.system(size: 17))
                        .buttonStyle(.bordered)
                    }

                    if !game.storeIdentifiers.isEmpty {
                        Text("Boutiques : " + GameDetailsFR.stores(for: game))
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.77))
                            .lineLimit(2)
                    }

                    HStack(alignment: .top, spacing: 26) {
                        metadata("DÉVELOPPEUR", game.developer)
                        metadata("ÉDITEUR", game.publisher)
                        metadata("CLASSIFICATION", game.rating)
                    }

                    Spacer(minLength: 6)

                    HStack(spacing: 18) {
                        Button { onPlay(game) } label: {
                            Label("Jouer", systemImage: "play.fill")
                                .font(.system(size: 22, weight: .medium))
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BoosteroidTheme.violet)
                        .focused($actionFocus, equals: .play)

                        Button { viewModel.toggleFavorite(game) } label: {
                            Label(
                                viewModel.isFavorite(game) ? "Retirer des favoris" : "Ajouter aux favoris",
                                systemImage: viewModel.isFavorite(game) ? "star.fill" : "star"
                            )
                            .font(.system(size: 21, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        .focused($actionFocus, equals: .favorite)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(42)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.33), in: RoundedRectangle(cornerRadius: 20))
            .padding(34)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder private func metadata(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.62))
                Text(value)
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
        }
    }

    @ViewBuilder private func posterArtwork(_ game: GameInfo) -> some View {
        if let value = game.boxArtUrl ?? game.heroBannerUrl, let url = URL(string: value) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFit()
                } else {
                    posterPlaceholder(game)
                }
            }
        } else {
            posterPlaceholder(game)
        }
    }

    private func posterPlaceholder(_ game: GameInfo) -> some View {
        BoosteroidTheme.cardGradient
            .overlay {
                VStack(spacing: 18) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 50))
                    Text(game.title)
                        .font(.headline)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
                .padding()
            }
    }

    @ViewBuilder private func carouselArtwork(_ game: GameInfo) -> some View {
        if let value = game.heroBannerUrl, let url = URL(string: value) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase { image.resizable().aspectRatio(contentMode: .fill) }
                else { BoosteroidTheme.cardGradient }
            }
        } else { BoosteroidTheme.cardGradient }
    }
}

private struct GameCard: View {
    let game: GameInfo
    let onPlay: (GameInfo) -> Void

    // No fixed aspect and no title. The card used to force a 2:3 portrait and
    // fill it, which cropped every game whose art isn't portrait — Boosteroid
    // only has cover art for some, and the rest fall back to a square icon or
    // a 16:9 banner. The card now takes its height from the artwork itself, so
    // each one is exactly the size of its image with nothing cut off and no
    // leftover gradient padding it out.
    var body: some View {
        Button { onPlay(game) } label: {
            artwork
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.card)
    }

    @ViewBuilder
    private var artwork: some View {
        if let value = game.boxArtUrl, let url = URL(string: value) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fit)
                case .failure:
                    bannerFallback
                case .empty:
                    placeholder
                @unknown default:
                    bannerFallback
                }
            }
        } else {
            bannerFallback
        }
    }

    @ViewBuilder
    private var bannerFallback: some View {
        if let value = game.heroBannerUrl, let url = URL(string: value) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().aspectRatio(contentMode: .fit)
                } else {
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    /// Square on purpose: with the card sized by its artwork, a shape with no
    /// intrinsic aspect would collapse to nothing while the image loads. This
    /// also carries the title, since it's the one case where the card has no
    /// art to identify the game by.
    private var placeholder: some View {
        Rectangle()
            .fill(BoosteroidTheme.cardGradient)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Text(game.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(10)
            }
    }
}

enum BoosteroidTheme {
    static let background = Color(red: 0.105, green: 0.115, blue: 0.13)
    static let violet = Color(red: 0.49, green: 0.23, blue: 0.93)
    static let indigo = Color(red: 0.31, green: 0.27, blue: 0.90)
    static let blue = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let accent = Color(red: 0.28, green: 0.92, blue: 0.38)

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [violet, indigo, blue], startPoint: .leading, endPoint: .trailing)
    }

    static var cardGradient: LinearGradient {
        LinearGradient(colors: [violet.opacity(0.7), indigo.opacity(0.7), blue.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
