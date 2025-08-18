import Foundation
import Supabase

// Reads Supabase config from Info.plist
enum AppConfig {
    private static func str(_ key: String) -> String {
        guard let s = Bundle.main.object(forInfoDictionaryKey: key) as? String, !s.isEmpty else {
            fatalError("Missing Info.plist key: \(key)")
        }
        return s
    }

    static var url: URL {
        let raw = str("SUPABASE_URL")
        guard let u = URL(string: raw) else { fatalError("Invalid SUPABASE_URL") }
        return u
    }

    static var anonKey: String { str("SUPABASE_ANON_KEY") }

    // Optional – only used for magic links; not needed for code verification.
    static var redirectURL: URL? {
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_REDIRECT_URL") as? String,
           let u = URL(string: s), !s.isEmpty {
            return u
        }
        return nil
    }
}

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.url,
            supabaseKey: AppConfig.anonKey
        )
    }
}
