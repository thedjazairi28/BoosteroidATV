import Foundation
import Security

/// A local-only credential record. Never persist this object to UserDefaults,
/// log it, or include it in any network request except the explicit remote
/// keyboard injection chosen by the user.
struct GameCredential: Codable {
    let username: String
    let password: String
}

enum GameAccountProvider: String, CaseIterable, Identifiable {
    case rockstar = "rockstar"
    case steam = "steam"
    case epic = "epic"
    case microsoft = "microsoft"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rockstar: return "Rockstar Games"
        case .steam: return "Steam"
        case .epic: return "Epic Games"
        case .microsoft: return "Xbox / Microsoft"
        }
    }

    static func suggested(for game: GameInfo) -> GameAccountProvider {
        let source = (game.storeIdentifiers + [game.title])
            .joined(separator: " ").lowercased()
        if source.contains("rockstar") || source.contains("red dead redemption") { return .rockstar }
        if source.contains("epic") { return .epic }
        if source.contains("xbox") || source.contains("microsoft") { return .microsoft }
        return .steam
    }
}

/// Keychain is encrypted at rest and tied to the sideloaded app identity.
/// Re-signing with a different application ID/team may cause records to become
/// inaccessible. No iCloud sync, web account, telemetry, or hard-coded secrets.
enum GameCredentialVault {
    private static let service = "BoosteroidATV.savedGameAccounts.v1"

    private static func query(_ provider: GameAccountProvider) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider.rawValue
        ]
    }

    static func save(_ record: GameCredential, for provider: GameAccountProvider) -> Bool {
        guard let bytes = try? JSONEncoder().encode(record) else { return false }
        let lookup = query(provider)
        let update: [String: Any] = [kSecValueData as String: bytes]

        let existingStatus = SecItemUpdate(lookup as CFDictionary, update as CFDictionary)
        if existingStatus == errSecSuccess { return true }
        guard existingStatus == errSecItemNotFound else { return false }

        var item = lookup
        item[kSecValueData as String] = bytes
        item[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(item as CFDictionary, nil) == errSecSuccess
    }

    static func load(_ provider: GameAccountProvider) -> GameCredential? {
        var lookup = query(provider)
        lookup[kSecReturnData as String] = true
        lookup[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        guard SecItemCopyMatching(lookup as CFDictionary, &result) == errSecSuccess,
              let bytes = result as? Data else { return nil }
        return try? JSONDecoder().decode(GameCredential.self, from: bytes)
    }

    static func contains(_ provider: GameAccountProvider) -> Bool {
        var lookup = query(provider)
        lookup[kSecReturnAttributes as String] = true
        lookup[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        return SecItemCopyMatching(lookup as CFDictionary, &result) == errSecSuccess
    }

    static func delete(_ provider: GameAccountProvider) -> Bool {
        let status = SecItemDelete(query(provider) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
