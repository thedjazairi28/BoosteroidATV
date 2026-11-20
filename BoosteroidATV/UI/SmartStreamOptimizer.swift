import Foundation

/// Conservative game-aware presets, evaluated once BEFORE opening a session.
/// This deliberately does not claim to optimize the remote PC's GPU or a
/// network connection: only the locally requested Boosteroid stream settings
/// are under our control. Manual mode leaves every saved setting unchanged.
enum SmartStreamOptimizer {
    enum Profile: String {
        case reactivity = "Réactivité"
        case quality = "Qualité d’image"
        case balanced = "Équilibré"
    }

    static func profile(for game: GameInfo) -> Profile {
        let metadata = (game.genres + game.tags + [game.title])
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()

        // A narrow category list avoids labeling every generic "Action"
        // title an FPS. The title fallbacks are for sparse catalog metadata.
        let reactiveHints = [
            "shooter", "first-person", "fps", "battle royale",
            "competitive", "esport", "multiplayer shooter",
            "battlefield", "call of duty", "counter-strike", "valorant",
            "overwatch", "apex legends", "rocket league",
            "ea sports fc", "fifa"
        ]
        if reactiveHints.contains(where: metadata.contains) { return .reactivity }

        let qualityHints = [
            "role-playing", "role playing", "rpg", "open world",
            "adventure", "story rich", "cinematic", "exploration",
            "red dead redemption", "cyberpunk", "alan wake",
            "the witcher", "hogwarts legacy"
        ]
        if qualityHints.contains(where: metadata.contains) { return .quality }
        return .balanced
    }

    static func settings(for game: GameInfo, preferred: StreamSettings) -> StreamSettings {
        guard preferred.smartOptimizationEnabled else { return preferred }

        var result = preferred
        // Let the existing verified server bandwidth ladder adapt to
        // resolution. Changing bandwidth dynamically in-session is left
        // to the existing control channel, not fabricated here.
        result.automaticBitrate = true

        // Do not silently request 120 FPS, AV1, HDR or 4K that the Apple TV
        // or Boosteroid session may not support. Keep the user's FPS limit,
        // codec, audio, controller, and diagnostic preferences untouched.
        //
        // For competitive titles, reduce an unnecessarily high requested
        // render resolution to 1080p to prioritize consistency. Never
        // upgrade a 720p preference behind the user's back.
        if profile(for: game) == .reactivity,
           result.resolution == "2560x1440" || result.resolution == "3840x2160" {
            result.resolution = "1920x1080"
        }
        return result
    }
}
