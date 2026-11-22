import CoreImage
import SwiftUI
import UIKit

/// Help content. Topics expand inline rather than pushing a detail screen —
/// each one is short enough that a push would be more navigation than the
/// content warrants, and inline keeps everything reachable with the Siri
/// Remote's d-pad alone.
///
/// Everything here describes behavior that actually exists in the app. The
/// original skeleton had two topics that never matched anything real
/// ("Steam Controller" — the app has a Steam OVERLAY button, not Steam
/// Controller support; "Specifications" — vague) and a Technical Support
/// section linking to a Discord and a Reddit that don't exist for this
/// project. Those were dropped rather than filled with invented content.
struct HelpView: View {
    @State private var expanded: Topic?

    private enum Topic: String, CaseIterable, Identifiable {
        case introduction = "Introduction"
        case gettingStarted = "Bien démarrer"
        case controlMethods = "Commandes"
        case steam = "Interface Steam"
        case duringGameplay = "Pendant une partie"
        case configuration = "Paramètres"
        case requirements = "Prérequis et limites"
        case troubleshooting = "Dépannage"

        var id: String { rawValue }

        var lines: [String] {
            switch self {
            case .introduction:
                return [
                    "BoosteroidATV est un client Boosteroid indépendant et open source pour Apple TV. Il permet de jouer en streaming avec une manette.",
                    "Cette application n'est ni officielle ni prise en charge par Boosteroid. Un abonnement actif est nécessaire."
                ]
            case .gettingStarted:
                return [
                    "• Connecte-toi avec l'adresse e-mail et le mot de passe de ton compte Boosteroid.",
                    "• Associe une manette dans Réglages tvOS → Télécommandes et appareils → Bluetooth.",
                    "• Sélectionne un jeu dans l'accueil ou la bibliothèque : l'application prépare la session.",
                    "Relancer un jeu peut reprendre la session précédente si elle est encore active."
                ]
            case .controlMethods:
                return [
                    "• Manettes compatibles : MFi, Xbox, PlayStation et Nintendo Switch. Les touches sont transmises au PC distant.",
                    "• La Siri Remote permet de naviguer dans l'application.",
                    "• Pour ouvrir le menu pendant un jeu, utilise Lecture/Pause ou Start + Select sur la manette.",
                    "• Le clavier virtuel est disponible dans le menu de session.",
                    "• Le mode Pointeur utilise la surface tactile de la Siri Remote comme souris et son clic central comme clic gauche."
                ]
            case .steam:
                return [
                    "Le bouton Interface Steam envoie le raccourci Maj + Tab au PC distant.",
                    "Si Steam prend en charge la navigation à la manette, utilise-la dans cette interface."
                ]
            case .duringGameplay:
                return [
                    "Ouvre ou ferme la barre d'options avec Lecture/Pause sur la Siri Remote ou Start + Select sur une manette.",
                    "• Déconnexion : quitte l'affichage du flux, mais Boosteroid peut garder la machine active quelque temps.",
                    "• Clavier : ouvre le clavier virtuel.",
                    "• Pointeur : permet de cliquer avec la Siri Remote.",
                    "• Interface Steam : affiche le panneau Steam.",
                    "• Performances : affiche débit, images par seconde et latence."
                ]
            case .configuration:
                return [
                    "• Qualité : de 720p à 4K et jusqu'à 120 images par seconde selon le service et le matériel.",
                    "• Débit : automatique ou plafond manuel.",
                    "• Manette : zone morte et vibrations.",
                    "• Diagnostics : affichage facultatif des performances.",
                    "• Région : serveur préféré ou régions éloignées, qui peuvent ajouter de la latence.",
                    "Les changements prennent effet lors du prochain lancement de jeu."
                ]
            case .requirements:
                return [
                    "• Apple TV sous tvOS 17 minimum.",
                    "• Abonnement Boosteroid actif.",
                    "• Réseau stable, idéalement Ethernet ou Wi-Fi 5 GHz.",
                    "L'application utilise H.264. Le transport natif Boosteroid nécessaire pour H.265 ou AV1 n'est pas implémenté."
                ]
            case .troubleshooting:
                return [
                    "• Connexion impossible : vérifie ton e-mail. Pour un compte créé avec Google, définis d'abord un mot de passe sur le site Boosteroid.",
                    "• Manette inactive : vérifie l'association Bluetooth sur l'Apple TV et relance la session.",
                    "• Vibrations absentes : vérifie le réglage. Certaines manettes tierces ne prennent pas en charge les vibrations.",
                    "• Qualité dégradée : surveille le débit et la latence dans les diagnostics.",
                    "• File d'attente longue : les régions éloignées peuvent offrir plus de serveurs, mais augmenter la latence.",
                    "• Écran noir : déconnecte-toi puis relance le jeu."
                ]
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                Text("Aide")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 12)

                VStack(spacing: 16) {
                    ForEach(Topic.allCases) { topic in
                        topicRow(topic)
                    }
                }
                .frame(maxWidth: 900)

                supportSection
                    .frame(maxWidth: 900, alignment: .leading)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 60)
            .padding(.vertical, 24)
        }
        .background(BoosteroidTheme.background.ignoresSafeArea())
    }

    @ViewBuilder
    private func topicRow(_ topic: Topic) -> some View {
        let isExpanded = expanded == topic

        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expanded = isExpanded ? nil : topic
                }
            } label: {
                HStack {
                    Text(topic.rawValue)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
            }
            .buttonStyle(.bordered)
            .tint(.gray)

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(topic.lines.enumerated()), id: \.offset) { _, line in
                        if line.hasPrefix("• ") {
                            HStack(alignment: .top, spacing: 12) {
                                Text("•")
                                Text(String(line.dropFirst(2)))
                            }
                        } else {
                            Text(line)
                        }
                    }
                }
                .font(.system(size: 24))
                // Not .secondary: on the dark background that renders too dim
                // to read comfortably from a couch.
                .foregroundStyle(.white.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                .padding(.top, 12)
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SOUTENIR LE PROJET")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.secondary)

            HStack(alignment: .center, spacing: 32) {
                // tvOS has no browser, so a tappable link would go nowhere —
                // a QR code is the only way to hand this URL off to a device
                // that can actually open it.
                if let qr = Self.donationQR {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 220, height: 220)
                        .padding(16)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Faire un don")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("BoosteroidATV est gratuit et open source. Pour soutenir son développement, scanne ce code avec ton téléphone.")
                        .font(.system(size: 22))
                        .foregroundStyle(.white.opacity(0.85))
                    Text(Self.donationURL)
                        .font(.system(size: 20, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private static let donationURL = "https://www.buymeacoffee.com/luizhdramos"

    /// Rendered once (static stored properties are lazy) rather than on every
    /// body evaluation — CoreImage rasterization is far too expensive to
    /// repeat on each SwiftUI update.
    private static let donationQR: UIImage? = makeQRCode(from: donationURL)

    private static func makeQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        // Medium error correction — enough tolerance for a photo taken of a
        // TV screen at an angle without inflating the module count.
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        // CIQRCodeGenerator emits roughly one pixel per module (~25x25pt), so
        // it has to be scaled up here. Scaling at render time instead would
        // resample and blur the modules; the .interpolation(.none) on the
        // Image above keeps the enlarged result crisp.
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        guard let cgImage = CIContext().createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
