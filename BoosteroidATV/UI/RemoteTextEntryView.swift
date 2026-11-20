import SwiftUI

/// Bridge between Apple's native tvOS text entry (also available from the
/// iPhone Apple TV Remote keyboard) and the already-focused remote Windows
/// game/launcher field. No passwords are stored on disk or sent to GitHub.
struct RemoteTextEntryView: View {
    let inputSender: InputSender?
    let onClose: () -> Void

    @State private var text = ""
    @State private var isPassword = false
    @State private var errorMessage: String?
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Saisie iPhone", systemImage: "iphone")
                    .font(.title3.bold())
                Spacer()
                Button("Fermer", systemImage: "xmark", action: close)
                    .buttonStyle(.bordered)
            }

            Text("Sélectionne d'abord le champ Rockstar avec le pointeur. Active ensuite le champ ci-dessous pour ouvrir le clavier Apple TV Remote sur ton iPhone.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                if isPassword {
                    SecureField("Mot de passe à envoyer", text: $text)
                        .focused($textFieldFocused)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                } else {
                    TextField("E-mail, identifiant ou texte", text: $text)
                        .focused($textFieldFocused)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                }
            }

            HStack(spacing: 20) {
                Toggle("Mot de passe (masquer)", isOn: $isPassword)
                    .frame(maxWidth: 380)
                Spacer()
                Button("Effacer") {
                    text = ""
                    errorMessage = nil
                }
                .buttonStyle(.bordered)
                Button {
                    send()
                } label: {
                    Label("Envoyer au PC", systemImage: "arrow.up.right")
                }
                .buttonStyle(.borderedProminent)
                .tint(BoosteroidTheme.violet)
                .disabled(text.isEmpty || inputSender == nil)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.orange)
            } else {
                Text("Seuls les caractères ASCII sont transmis pour l'instant. Le texte n'est pas enregistré.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.white)
        .padding(26)
        .frame(maxWidth: 1080)
        .background(.black.opacity(0.96), in: RoundedRectangle(cornerRadius: 22))
        .onExitCommand(perform: close)
    }

    private func send() {
        guard let inputSender, !text.isEmpty else { return }
        guard inputSender.typeRemoteText(text) else {
            errorMessage = "Un caractère n'est pas pris en charge. Utilise des caractères sans accents."
            return
        }
        text = ""
        errorMessage = nil
        onClose()
    }

    private func close() {
        text = ""
        errorMessage = nil
        onClose()
    }
}
