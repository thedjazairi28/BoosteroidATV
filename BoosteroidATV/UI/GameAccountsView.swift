import SwiftUI

/// Local password manager for supported launchers. The Apple TV Remote
/// keyboard can enter these native tvOS TextField/SecureField controls.
/// Credentials are NOT automatically injected when a remote window appears.
struct GameAccountsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProvider: GameAccountProvider = .rockstar
    @State private var username = ""
    @State private var password = ""
    @State private var feedback: String?
    @State private var configured: Set<GameAccountProvider> = []

    var body: some View {
        ZStack {
            BoosteroidTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Label("Comptes de jeux", systemImage: "lock.shield")
                            .font(.largeTitle.bold())
                        Spacer()
                        Button("Fermer") { close() }
                            .buttonStyle(.bordered)
                    }

                    Text("Enregistrement local dans le Keychain de cette Apple TV. Aucun mot de passe n'est envoyé à Boosteroid avant une action explicite dans le jeu.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 16) {
                        ForEach(GameAccountProvider.allCases) { provider in
                            Button {
                                select(provider)
                            } label: {
                                VStack(spacing: 6) {
                                    Text(provider.title)
                                        .font(.headline)
                                    Label(configured.contains(provider) ? "Enregistré" : "Non configuré",
                                          systemImage: configured.contains(provider) ? "checkmark.circle" : "plus.circle")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(8)
                            }
                            .buttonStyle(.bordered)
                            .tint(selectedProvider == provider ? BoosteroidTheme.violet : .gray)
                        }
                    }

                    Text("Configurer : \(selectedProvider.title)")
                        .font(.title2.bold())

                    TextField("E-mail ou identifiant", text: $username)
                        .textFieldStyle(.automatic)

                    SecureField("Mot de passe", text: $password)
                        .textFieldStyle(.automatic)

                    Text("La saisie est temporaire. Lors de l'enregistrement, le mot de passe remplace le précédent. Il ne sera jamais réaffiché ici.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 18) {
                        Button("Enregistrer") {
                            save()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(BoosteroidTheme.violet)
                        .disabled(username.isEmpty || password.isEmpty)

                        if configured.contains(selectedProvider) {
                            Button("Supprimer ce compte", role: .destructive) {
                                if GameCredentialVault.delete(selectedProvider) {
                                    username = ""
                                    password = ""
                                    feedback = "Compte supprimé du Keychain."
                                    reload()
                                } else {
                                    feedback = "Suppression impossible."
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    if let feedback {
                        Text(feedback)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Text("Sécurité : la TV ne possède pas l'équivalent du déverrouillage biométrique Dashlane. Toute personne ayant accès à cette application et à ta session TV pourrait demander l'envoi d'un identifiant enregistré.")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 1080, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(64)
            }
        }
        .tint(BoosteroidTheme.violet)
        .onAppear { reload() }
        .onDisappear { password = "" }
        .onExitCommand(perform: close)
    }

    private func select(_ provider: GameAccountProvider) {
        selectedProvider = provider
        username = ""
        password = ""
        feedback = nil
    }

    private func save() {
        let entry = GameCredential(username: username, password: password)
        if GameCredentialVault.save(entry, for: selectedProvider) {
            feedback = "Identifiants enregistrés localement."
            password = ""
            reload()
        } else {
            feedback = "Échec d'enregistrement dans le Keychain."
        }
    }

    private func reload() {
        configured = Set(GameAccountProvider.allCases.filter(GameCredentialVault.contains))
    }

    private func close() {
        password = ""
        dismiss()
    }
}
