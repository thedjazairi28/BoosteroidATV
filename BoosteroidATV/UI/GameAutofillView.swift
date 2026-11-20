import SwiftUI

/// Explicit, focus-safe autofill: the user must have selected the destination
/// field in the remote launcher before opening this panel, then chooses
/// separately whether to inject the username or the password.
/// We never infer a launcher by inspecting video and never submit forms/MFA.
struct GameAutofillView: View {
    let inputSender: InputSender?
    let onClose: () -> Void

    @State private var selectedProvider: GameAccountProvider
    @State private var errorMessage: String?

    init(inputSender: InputSender?, suggestedProvider: GameAccountProvider, onClose: @escaping () -> Void) {
        self.inputSender = inputSender
        self.onClose = onClose
        self._selectedProvider = State(initialValue: suggestedProvider)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Label("Mes comptes", systemImage: "key.fill")
                    .font(.title2.bold())
                Spacer()
                Button("Fermer") { onClose() }
                    .buttonStyle(.bordered)
            }

            Text("Sélectionne d’abord le bon champ sur le PC distant avec le pointeur. Seul le bouton que tu choisis enverra du texte.")
                .foregroundStyle(.secondary)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                ForEach(GameAccountProvider.allCases) { provider in
                    Button(provider.title) {
                        selectedProvider = provider
                        errorMessage = nil
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedProvider == provider ? BoosteroidTheme.violet : .gray)
                }
            }

            if GameCredentialVault.contains(selectedProvider) {
                HStack(spacing: 18) {
                    Button {
                        sendPassword(isPassword: false)
                    } label: {
                        Label("Envoyer l’identifiant", systemImage: "person.text.rectangle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(BoosteroidTheme.violet)
                    .disabled(inputSender == nil)

                    Button {
                        sendPassword(isPassword: true)
                    } label: {
                        Label("Envoyer le mot de passe", systemImage: "lock")
                    }
                    .buttonStyle(.bordered)
                    .disabled(inputSender == nil)
                }
            } else {
                Label("Aucun compte enregistré pour \(selectedProvider.title). Configure-le depuis Paramètres → Comptes de jeux.",
                      systemImage: "info.circle")
                    .font(.callout)
                    .foregroundStyle(.orange)
            }

            if let errorMessage {
                Text(errorMessage).font(.callout).foregroundStyle(.orange)
            } else {
                Text("Le Keychain reste local à l’Apple TV. Aucun remplissage automatique non sollicité.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.white)
        .padding(26)
        .frame(maxWidth: 1080)
        .background(.black.opacity(0.96), in: RoundedRectangle(cornerRadius: 22))
        .onExitCommand(perform: onClose)
    }

    private func sendPassword(isPassword: Bool) {
        guard let credential = GameCredentialVault.load(selectedProvider),
              let inputSender else {
            errorMessage = "Compte indisponible."
            return
        }
        let value = isPassword ? credential.password : credential.username
        guard inputSender.typeRemoteText(value) else {
            errorMessage = "Ce compte comporte un caractère non pris en charge (ASCII uniquement). Aucune frappe n’a été envoyée."
            return
        }
        onClose()
    }
}
