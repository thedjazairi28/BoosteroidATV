import Foundation
import Security
import UIKit

/// Upload reports only after an explicit button press.
/// The personal access token is kept in this device's Keychain, never in the
/// source, UserDefaults, report body, or the event trace.
enum DiagnosticIssueCredentials {
    private static let service = "BoosteroidATV.DiagnosticIssues"
    private static let account = "github-issues-token"

    static func load() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Update without removing the previous credential first. The earlier
    /// delete-then-add flow could lose a working token if the insert failed.
    @discardableResult
    static func save(_ token: String) -> Bool {
        let sanitized = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitized.isEmpty, let data = sanitized.data(using: .utf8) else { return false }

        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        let update: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(identity as CFDictionary, update as CFDictionary)
        if updateStatus == errSecSuccess { return true }
        guard updateStatus == errSecItemNotFound else { return false }

        var insertion = identity
        insertion[kSecValueData as String] = data
        insertion[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(insertion as CFDictionary, nil) == errSecSuccess
    }

    static func delete() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

@MainActor
enum DiagnosticGitHubReporter {
    struct Result {
        let issueNumber: Int
        let url: String
    }

    enum ReportError: LocalizedError {
        case invalidRepository
        case noEvents
        case unauthorized
        case forbidden
        case repoNotFound
        case http(Int)
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .invalidRepository: "Dépôt invalide : utilise propriétaire/nom."
            case .noEvents: "Aucun événement à envoyer."
            case .unauthorized: "Jeton GitHub invalide ou expiré (HTTP 401)."
            case .forbidden: "Accès refusé : vérifie le droit Issues en écriture (HTTP 403)."
            case .repoNotFound: "Dépôt introuvable, non accessible ou Issues désactivées (HTTP 404)."
            case .http(let status): "Erreur GitHub HTTP \(status)."
            case .invalidResponse: "Réponse GitHub inattendue."
            }
        }
    }

    private struct CreatedIssue: Decodable {
        let number: Int
        let html_url: String
    }

    static func send(
        repository: String,
        token: String,
        entries: [LaunchTrace.Entry],
        checkpoint: String,
        interrupted: Bool
    ) async throws -> Result {
        let parts = repository.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2,
              parts.allSatisfy({ !$0.isEmpty && $0.range(of: #"^[A-Za-z0-9_.-]+$"#, options: .regularExpression) != nil }),
              !entries.isEmpty else {
            if entries.isEmpty { throw ReportError.noEvents }
            throw ReportError.invalidRepository
        }

        // URL is created exclusively from validated GitHub owner/repo parts.
        let endpoint = URL(string: "https://api.github.com/repos/\(parts[0])/\(parts[1])/issues")!
        let now = ISO8601DateFormatter().string(from: Date())
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "inconnue"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "inconnu"

        // Whitelisted app events only: never attach raw HTTP payloads, login
        // data, cookies, session IDs, private endpoints, or OS crash dumps.
        let formatter = ISO8601DateFormatter()
        let events = entries.suffix(80).map { entry in
            "\(formatter.string(from: entry.time)) [\(sanitize(entry.level))] \(sanitize(entry.message))"
        }.joined(separator: "\n")

        let body = """
        ## Diagnostic BoosteroidATV (envoi volontaire)

        - Date UTC : \(now)
        - Version : \(sanitize(appVersion)) (build \(sanitize(build)))
        - tvOS : \(sanitize(UIDevice.current.systemVersion))
        - Lancement interrompu sans fermeture normale : \(interrupted ? "oui" : "non")
        - Dernière étape : \(sanitize(checkpoint))

        ## 80 derniers événements au maximum

        ```text
        \(events)
        ```

        _Ce rapport contient uniquement les événements applicatifs filtrés.
        Il ne constitue pas un rapport de crash natif tvOS / Jetsam._
        """

        let payload = [
            "title": "[Diagnostic tvOS] Lancement de jeu — \(now)",
            "body": body,
        ]
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ReportError.invalidResponse }
        switch http.statusCode {
        case 201: break
        case 401: throw ReportError.unauthorized
        case 403: throw ReportError.forbidden
        case 404: throw ReportError.repoNotFound
        default: throw ReportError.http(http.statusCode)
        }

        let issue = try JSONDecoder().decode(CreatedIssue.self, from: data)
        guard let url = URL(string: issue.html_url),
              url.scheme == "https", url.host == "github.com" else {
            throw ReportError.invalidResponse
        }
        return Result(issueNumber: issue.number, url: issue.html_url)
    }

    private static func sanitize(_ original: String) -> String {
        var value = String(original.prefix(160))
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\r", with: " ")
            .replacingOccurrences(of: "```", with: "'''")
        value = value.replacingOccurrences(
            of: #"https?://[^\s]+"#, with: "[URL masquée]", options: .regularExpression)
        value = value.replacingOccurrences(
            of: #"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#,
            with: "[courriel masqué]", options: .regularExpression)
        value = value.replacingOccurrences(
            of: #"(?i)\b(token|password|cookie|authorization|bearer|sessionid)\s*[:=]\s*\S+"#,
            with: "[valeur masquée]", options: .regularExpression)
        return String(value.prefix(135))
    }
}
