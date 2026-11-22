import SwiftUI

struct SettingsView: View {
    @Environment(AuthManager.self) var authManager
    @Environment(GamesViewModel.self) var viewModel
    @State private var showGameAccounts = false
    @AppStorage("boosteroid.previewVideosEnabled") private var previewVideosEnabled = false
    @AppStorage("boosteroid.launch.lastCheckpoint") private var lastLaunchCheckpoint = "Aucune tentative enregistrée"
    @AppStorage("boosteroid.launch.inProgress") private var launchInProgress = false
    @AppStorage("boosteroid.launch.showLiveLog") private var showLiveLog = true
    @State private var launchTrace = LaunchTrace.shared
    @AppStorage("boosteroid.diagnostics.issueRepository") private var issueRepository = "thedjazairi28/BoosteroidATV"
    @State private var newIssueToken = ""
    @State private var issueTokenStored = false
    @State private var isSendingIssue = false
    @State private var issueReportStatus: String?
    @State private var issueReportURL: String?
    @State private var showKeychainFeedback = false
    @State private var keychainFeedbackMessage = ""

    private let resolutions: [(String, String)] = [
        ("720p", "1280x720"), ("1080p", "1920x1080"),
        ("1440p", "2560x1440"), ("4K", "3840x2160"),
    ]
    // 30 removed 2026-08-06: Boosteroid never delivers below 60, so offering
    // it only created a setting that silently did nothing.
    private let fpsOptions: [(String, Int)] = [("60", 60), ("120", 120)]

    var body: some View {
        @Bindable var viewModel = viewModel
        // Plain ScrollView with hand-built sections instead of `Form`: on the
        // app's dark background Form's own chrome/section headers rendered
        // dark-on-dark and became unreadable. Explicit colors here guarantee
        // contrast. No navigation title either — the top bar already says
        // "Settings".
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                section("Comptes de jeux") {
                    Button {
                        showGameAccounts = true
                    } label: {
                        Label("Gérer mes identifiants Rockstar, Steam, Epic et Xbox", systemImage: "lock.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    Text("Sauvegarde locale Keychain ; remplissage sur demande uniquement pendant le jeu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                section("Qualité du streaming") {
                    OptionRow(title: "Résolution", options: resolutions,
                              selection: $viewModel.streamSettings.resolution)
                    OptionRow(title: "FPS", options: fpsOptions,
                              selection: $viewModel.streamSettings.fps)
                }
                section("Optimisation intelligente") {
                    SettingsToggle("Profil automatique par jeu", isOn: $viewModel.streamSettings.smartOptimizationEnabled)
                    Text("Activé : priorité à la réactivité pour les jeux compétitifs, à la qualité pour les aventures. Les paramètres sont appliqués au démarrage uniquement. Désactive pour conserver les réglages manuels.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                section("Débit vidéo") {
                    SettingsToggle("Débit automatique", isOn: $viewModel.streamSettings.automaticBitrate)
                    if !viewModel.streamSettings.automaticBitrate {
                        StepperRow(
                            title: "Débit maximal",
                            value: "\(viewModel.streamSettings.manualBitrateMbps) Mbps",
                            onDecrease: { viewModel.streamSettings.manualBitrateMbps -= 5 },
                            onIncrease: { viewModel.streamSettings.manualBitrateMbps += 5 }
                        )
                    }
                }
                section("Manette") {
                    StepperRow(
                        title: "Zone morte",
                        value: "\(Int(viewModel.streamSettings.controllerDeadzone * 100))%",
                        onDecrease: { viewModel.streamSettings.controllerDeadzone = max(0, viewModel.streamSettings.controllerDeadzone - 0.05) },
                        onIncrease: { viewModel.streamSettings.controllerDeadzone = min(0.5, viewModel.streamSettings.controllerDeadzone + 0.05) }
                    )
                    SettingsToggle("Vibrations de la manette", isOn: $viewModel.streamSettings.rumbleEnabled)
                    if viewModel.streamSettings.rumbleEnabled {
                        HStack(spacing: 16) {
                            Text("Intensité des vibrations")
                            Spacer()
                            // Menu dropdown, same reasoning as the region
                            // picker below: a row of buttons per option
                            // reads worse than a single dropdown once
                            // there's more than a couple of choices.
                            Menu {
                                ForEach(RumbleIntensity.allCases, id: \.self) { intensity in
                                    Button {
                                        viewModel.streamSettings.rumbleIntensity = intensity
                                    } label: {
                                        if viewModel.streamSettings.rumbleIntensity == intensity {
                                            Label(intensity.displayName, systemImage: "checkmark")
                                        } else {
                                            Text(intensity.displayName)
                                        }
                                    }
                                }
                            } label: {
                                Label(viewModel.streamSettings.rumbleIntensity.displayName, systemImage: "chevron.up.chevron.down")
                            }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                        }
                    }
                    Text("Ce réglage s’appliquera au prochain lancement d’un jeu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                section("Sécurité du lancement") {
                    SettingsToggle("Aperçus vidéo animés (expérimental)", isOn: $previewVideosEnabled)
                    Text("Désactivés par défaut pour limiter le chevauchement entre les bandes-annonces et le décodeur du jeu. Les fiches conservent leur illustration et leur description.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if previewVideosEnabled {
                        Text("Si l'application se ferme au lancement d'un jeu, désactive cette option avant de réessayer.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
                section("Diagnostics") {
                    SettingsToggle("Journal de lancement à l'écran", isOn: $showLiveLog)
                    Text("Affiche les principales étapes de lancement en direct. Les 80 derniers événements restent consultables ici après une fermeture inattendue.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    SettingsToggle("Afficher les performances pendant le jeu", isOn: $viewModel.streamSettings.showStatsOverlay)

                    Text("Dernière étape de lancement : " + lastLaunchCheckpoint)
                        .font(.callout)
                        .foregroundStyle(launchInProgress ? .orange : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if launchInProgress {
                        Text("La dernière tentative n'a pas enregistré de fermeture normale (crash ou interruption possibles).")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    HStack {
                        Text("JOURNAL DES ÉVÉNEMENTS")
                            .font(.headline)
                        Spacer()
                        Button("Effacer") {
                            launchTrace.clear()
                        }
                        .buttonStyle(.bordered)
                        .disabled(launchTrace.entries.isEmpty)
                    }
                    if launchTrace.entries.isEmpty {
                        Text("Aucun événement enregistré. Lance un jeu pour alimenter le journal.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(launchTrace.entries.suffix(35).reversed())) { entry in
                            HStack(alignment: .firstTextBaseline, spacing: 14) {
                                Text(entry.time, format: .dateTime.hour().minute().second())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 116, alignment: .leading)
                                Text(entry.level)
                                    .foregroundStyle(entry.level == "ERREUR" ? Color.red
                                        : entry.level == "OK" ? Color.green : Color.yellow)
                                    .frame(width: 90, alignment: .leading)
                                Text(entry.message)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .font(.system(size: 16, design: .monospaced))
                        }
                    }
                    Divider()
                        .padding(.vertical, 10)
                    Text("ENVOI D'UN RAPPORT SUR GITHUB")
                        .font(.headline)
                    Text("Un clic crée un ticket GitHub contenant les événements techniques conservés ci-dessus. Aucun envoi automatique.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField("Dépôt (propriétaire/nom)", text: $issueRepository)
                    SecureField("Jeton GitHub (Issues : Read and write)", text: $newIssueToken)
                    HStack(spacing: 14) {
                        Button(issueTokenStored ? "Remplacer le jeton" : "Enregistrer le jeton") {
                            let saved = DiagnosticIssueCredentials.save(newIssueToken)
                            // Never keep the user-entered secret in view state after saving.
                            newIssueToken = ""
                            // Confirm the actual Keychain read, not just SecItemAdd/Update.
                            issueTokenStored = DiagnosticIssueCredentials.load() != nil
                            issueReportStatus = saved && issueTokenStored
                                ? "Jeton enregistré et relu depuis le Keychain de l'Apple TV."
                                : (issueTokenStored
                                    ? "Remplacement impossible : le jeton précédent est conservé."
                                    : "Échec du stockage local : réessaie sans désinstaller l'application.")
                            keychainFeedbackMessage = issueReportStatus ?? "État du Keychain indisponible."
                            showKeychainFeedback = true
                        }
                        .disabled(newIssueToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .buttonStyle(.bordered)
                        Button("Vérifier le Keychain") {
                            let verification = DiagnosticIssueCredentials.checkStatus()
                            issueTokenStored = verification.available
                            issueReportStatus = verification.message
                            keychainFeedbackMessage = verification.message
                            showKeychainFeedback = true
                        }
                        .buttonStyle(.bordered)
                        if issueTokenStored {
                            Button("Supprimer le jeton") {
                                DiagnosticIssueCredentials.delete()
                                issueTokenStored = DiagnosticIssueCredentials.load() != nil
                                newIssueToken = ""
                                issueReportStatus = issueTokenStored
                                    ? "Impossible de supprimer le jeton."
                                    : "Jeton supprimé du Keychain de l'Apple TV."
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                    if let issueReportStatus {
                        Label(issueReportStatus,
                              systemImage: issueTokenStored ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(issueTokenStored ? Color.green : Color.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text(issueTokenStored
                         ? "Jeton enregistré localement. Il n'est ni affiché ni inclus dans le rapport. Le premier envoi vérifiera aussi les droits GitHub."
                         : "Entre un jeton GitHub à accès limité, puis sélectionne Enregistrer le jeton. Le secret ne figure jamais dans l'IPA.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        Task { await sendDiagnosticIssue() }
                    } label: {
                        Label(isSendingIssue ? "Envoi en cours…" : "Envoyer un rapport d'erreur",
                              systemImage: "paperplane")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSendingIssue || !issueTokenStored || launchTrace.entries.isEmpty)
                    if let issueReportURL {
                        Text(issueReportURL)
                            .font(.caption)
                            .foregroundStyle(.green)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Confidentialité : si le dépôt choisi est public, le rapport GitHub le sera aussi. Préfère un dépôt privé pour les diagnostics. Une erreur fatale tvOS/Jetsam n'est pas incluse dans ce journal.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Sécurité : seuls les jalons techniques définis dans le code sont enregistrés. Aucun identifiant, mot de passe, jeton, URL privée ou contenu brut de réponse réseau n'est inclus.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                section("Région du serveur") {
                    SettingsToggle("Autoriser les serveurs éloignés", isOn: allowDistantRegionsBinding)
                    Text("Donne accès à davantage de serveurs, mais peut augmenter la latence et les interruptions.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let regionSettingsError = viewModel.regionSettingsError {
                        Text(regionSettingsError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    HStack(spacing: 16) {
                        Text("Serveur préféré")
                        Spacer()
                        // A grid of ~24 buttons (one per playground) was
                        // unreadable — per feedback, a dropdown Menu (like
                        // the real account-settings page's own select)
                        // scales to any number of locations without eating
                        // half the screen. SwiftUI's Menu renders as a
                        // proper tvOS popover (unlike Picker's pushed
                        // destination, which the OptionRow doc comment
                        // above notes renders blank here), so this is safe
                        // where Picker wasn't.
                        Menu {
                            Button {
                                Task { await viewModel.setPreferredPlayground(nil, authManager: authManager) }
                            } label: {
                                if viewModel.preferredPlaygroundId == nil {
                                    Label("Emplacement automatique", systemImage: "checkmark")
                                } else {
                                    Text("Emplacement automatique")
                                }
                            }
                            ForEach(viewModel.playgrounds) { playground in
                                Button {
                                    Task { await viewModel.setPreferredPlayground(playground.id, authManager: authManager) }
                                } label: {
                                    if viewModel.preferredPlaygroundId == playground.id {
                                        Label(playground.displayName, systemImage: "checkmark")
                                    } else {
                                        Text(playground.displayName)
                                    }
                                }
                            }
                        } label: {
                            Label(selectedPlaygroundLabel, systemImage: "chevron.up.chevron.down")
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    }
                    Text("Ce réglage s'appliquera au prochain lancement de jeu.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                section("Compte Boosteroid") {
                    Button("Se déconnecter") { authManager.logout() }
                        .buttonStyle(.bordered)
                        .tint(.red)
                }
            }
            .frame(maxWidth: 1100, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 60)
            .padding(.vertical, 24)
        }
        // Settings controls use Boosteroid's brand color. Interactive focus
        // remains white/black for contrast instead of inheriting the app's
        // green launch accent.
        .tint(BoosteroidTheme.violet)
        .fullScreenCover(isPresented: $showGameAccounts) {
            GameAccountsView()
        }
        .onAppear {
            issueTokenStored = DiagnosticIssueCredentials.load() != nil
        }
        .alert("Diagnostic Keychain", isPresented: $showKeychainFeedback) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(keychainFeedbackMessage)
        }
    }

    private func sendDiagnosticIssue() async {
        guard !isSendingIssue else { return }
        guard let token = DiagnosticIssueCredentials.load() else {
            issueTokenStored = false
            issueReportStatus = "Jeton GitHub absent : enregistre-le dans les réglages."
            return
        }
        isSendingIssue = true
        issueReportStatus = nil
        issueReportURL = nil
        defer { isSendingIssue = false }
        do {
            let issue = try await DiagnosticGitHubReporter.send(
                repository: issueRepository,
                token: token,
                entries: launchTrace.entries,
                checkpoint: lastLaunchCheckpoint,
                interrupted: launchInProgress
            )
            issueReportStatus = "Rapport #\(issue.issueNumber) envoyé sur GitHub."
            issueReportURL = issue.url
        } catch {
            issueReportStatus = "Envoi impossible : \(error.localizedDescription)"
        }
    }

    /// Mirrors cloud.boosteroid.com/profile/account/main's "Permitir ligação
    /// a regiões distantes" toggle (see GamesViewModel.setAllowDistantRegions
    /// / BoosteroidClient's Streaming Regions section for the confirmed
    /// PATCH this drives). The write is async and server-side, so this is a
    /// custom Binding rather than a plain `$viewModel.foo` — the setter fires
    /// a Task instead of writing synchronously.
    private var allowDistantRegionsBinding: Binding<Bool> {
        Binding(
            get: { viewModel.allowDistantRegions },
            set: { newValue in
                Task { await viewModel.setAllowDistantRegions(newValue, authManager: authManager) }
            }
        )
    }

    /// The Menu button's own label — the currently selected location's name,
    /// or "Automatic Location" while `preferredPlaygroundId` is nil.
    private var selectedPlaygroundLabel: String {
        guard let id = viewModel.preferredPlaygroundId else { return "Emplacement automatique" }
        return viewModel.playgrounds.first(where: { $0.id == id })?.displayName ?? "Emplacement automatique"
    }

    /// One titled settings group: a bright header over its rows on a subtle
    /// translucent card, so both stay legible on the dark page background.
    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.secondary)
            // NOTE: deliberately no blanket .foregroundStyle(.white) here.
            // On tvOS a focused button/toggle fills white and the system
            // inverts its label to dark; forcing white would override that
            // inversion and render white-on-white. Plain labels set their own
            // color individually instead.
            VStack(alignment: .leading, spacing: 20) {
                content()
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

/// A tvOS value stepper: a label, a centered value, and bordered −/+ buttons.
/// tvOS has no `Slider`/`Stepper`, so this is the adjuster pattern. Bordered
/// buttons (same style as `OptionRow`) give a clear, high-contrast focus state
/// — unlike borderless icon buttons, whose symbol turns white and blends into
/// the surrounding white text when focused. Focus the − or + button and press
/// the select/click button to change the value (left/right moves between them).
private struct StepperRow: View {
    let title: String
    let value: String
    var onDecrease: () -> Void
    var onIncrease: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
            Spacer()
            SettingsIconButton(systemName: "minus", action: onDecrease)
            Text(value)
                .monospacedDigit()
                .foregroundStyle(.white.opacity(0.82))
                .frame(minWidth: 130)
                .multilineTextAlignment(.center)
            SettingsIconButton(systemName: "plus", action: onIncrease)
        }
    }
}

/// A tvOS-friendly single-choice selector: a label plus one focusable button
/// per option, the selected one highlighted. Avoids SwiftUI's `Picker`, whose
/// pushed selection screen renders blank inside a Form/TabView on tvOS.
private struct OptionRow<Value: Hashable>: View {
    let title: String
    let options: [(String, Value)]
    @Binding var selection: Value

    var body: some View {
        HStack(spacing: 16) {
            Text(title)
            Spacer()
            ForEach(options, id: \.1) { label, value in
                SettingsOptionButton(
                    label: label,
                    isSelected: selection == value,
                    action: { selection = value }
                )
            }
        }
    }
}

/// A focus-aware settings toggle. The standard tvOS Toggle changes its bar
/// to white on focus without reliably changing its label/value color, making
/// both disappear. Drawing the row explicitly keeps focused text black.
private struct SettingsToggle: View {
    let title: String
    @Binding var isOn: Bool
    @FocusState private var isFocused: Bool

    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }

    var body: some View {
        Button { isOn.toggle() } label: {
            HStack {
                Text(title)
                Spacer()
                Text(isOn ? "Activé" : "Désactivé")
            }
            .font(.body)
            .foregroundStyle(isFocused ? .black : .white)
            .padding(.horizontal, 28)
            .frame(minHeight: 66)
            .background(
                isFocused ? Color.white : BoosteroidTheme.violet,
                in: Capsule()
            )
        }
        .buttonStyle(SettingsPassthroughButtonStyle())
        .focused($isFocused)
        .focusEffectDisabled()
        .animation(.easeOut(duration: 0.12), value: isFocused)
    }
}

/// Explicit focus colors avoid tvOS applying a white focus fill while leaving
/// a white label, which made selected values such as 1080p/60 disappear.
private struct SettingsOptionButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.body.weight(.semibold))
                .foregroundStyle(isFocused ? .black : .white)
                .padding(.horizontal, 18)
                .frame(minHeight: 54)
                .background(
                    isFocused ? Color.white
                        : isSelected ? BoosteroidTheme.violet
                        : Color.white.opacity(0.16),
                    in: Capsule()
                )
        }
        .buttonStyle(SettingsPassthroughButtonStyle())
        .focused($isFocused)
        .focusEffectDisabled()
        .animation(.easeOut(duration: 0.12), value: isFocused)
    }
}

/// The minus/plus symbols get their own foreground color instead of
/// inheriting the tint, so they stay visible in every focus state.
private struct SettingsIconButton: View {
    let systemName: String
    let action: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.body.weight(.bold))
                .foregroundStyle(isFocused ? .black : .white)
                .frame(width: 74, height: 58)
                .background(
                    isFocused ? Color.white : BoosteroidTheme.violet,
                    in: Capsule()
                )
        }
        .buttonStyle(SettingsPassthroughButtonStyle())
        .focused($isFocused)
        .focusEffectDisabled()
        .animation(.easeOut(duration: 0.12), value: isFocused)
    }
}

/// tvOS's built-in button styles add a second, oversized white focus capsule.
/// This style preserves Button activation/focus behavior while rendering only
/// the compact focus background supplied by the control itself.
private struct SettingsPassthroughButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.78 : 1)
    }
}
