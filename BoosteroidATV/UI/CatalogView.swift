import SwiftUI

/// One searchable surface for the observed Installer collection plus My Library.
/// Other Boosteroid collections will be added once their API requests are verified.
struct CatalogView: View {
    let games: [GameInfo]
    let isLoading: Bool
    let error: String?
    let onSelect: (GameInfo) -> Void
    let onRefresh: () async -> Void

    @State private var searchText = ""
    @State private var selectedStore: StoreFilter = .all

    private enum StoreFilter: String, CaseIterable, Identifiable {
        case all = "Tous"
        case steam = "Steam"
        case xbox = "Xbox"
        case epic = "Epic Games"

        var id: String { rawValue }

        func includes(_ game: GameInfo) -> Bool {
            if self == .all { return true }
            let keys = game.storeIdentifiers.joined(separator: " ").lowercased()
            let title = game.title.lowercased()
            switch self {
            case .all: return true
            case .steam: return keys.contains("steam") || title.contains("(steam)")
            case .xbox: return keys.contains("xbox") || keys.contains("microsoft") || title.contains("(xbox)")
            case .epic: return keys.contains("epic") || title.contains("(epic)")
            }
        }
    }

    private var filteredGames: [GameInfo] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return games.filter { game in
            (query.isEmpty || game.title.localizedCaseInsensitiveContains(query))
            && selectedStore.includes(game)
        }
    }

    var body: some View {
        ZStack {
            BoosteroidTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Catalogue")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            Text("\(filteredGames.count) jeux affichés · Collections Boosteroid et bibliothèque")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Menu {
                            ForEach(StoreFilter.allCases) { filter in
                                Button(filter.rawValue) { selectedStore = filter }
                            }
                        } label: {
                            Label(selectedStore.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                        }
                        .buttonStyle(.bordered)

                        Button {
                            Task { await onRefresh() }
                        } label: {
                            Label("Actualiser", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    }

                    if let error {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }

                    if isLoading && games.isEmpty {
                        HStack(spacing: 16) {
                            ProgressView()
                            Text("Chargement du catalogue Boosteroid…")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 50)
                    } else if filteredGames.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 245, maximum: 280), spacing: 28)],
                            spacing: 32
                        ) {
                            ForEach(filteredGames) { game in
                                CatalogGameTile(game: game) { onSelect(game) }
                            }
                        }
                    }
                }
                .padding(.horizontal, 60)
                .padding(.top, 40)
                .padding(.bottom, 80)
            }
        }
        .searchable(text: $searchText, prompt: "Rechercher dans le catalogue")
    }
}

private struct CatalogGameTile: View {
    let game: GameInfo
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                artwork
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(game.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Label(
                    game.requiresInstallation ? "Installer et jouer" : "Prêt à jouer",
                    systemImage: game.requiresInstallation ? "square.and.arrow.down" : "play.fill"
                )
                .font(.caption)
                .foregroundStyle(game.requiresInstallation ? .orange : BoosteroidTheme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.card)
    }

    @ViewBuilder
    private var artwork: some View {
        if let address = game.boxArtUrl, let url = URL(string: address) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Rectangle()
            .fill(BoosteroidTheme.cardGradient)
            .overlay {
                Image(systemName: "gamecontroller.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.6))
            }
    }
}
