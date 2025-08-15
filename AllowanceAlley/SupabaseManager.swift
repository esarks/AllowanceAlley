import Foundation
import Supabase

// MARK: - AppConfig (loads from Info.plist first, then Process env)
enum AppConfig {
    static var url: URL {
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
           let u = URL(string: s) { return u }
        if let s = ProcessInfo.processInfo.environment["SUPABASE_URL"],
           let u = URL(string: s) { return u }
        fatalError("Missing SUPABASE_URL")
    }

    static var anonKey: String {
        if let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String { return s }
        if let s = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] { return s }
        fatalError("Missing SUPABASE_ANON_KEY")
    }
}

final class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient

    private init() {
        let url = AppConfig.url
        let key = AppConfig.anonKey

        #if DEBUG
        print("🧭 [Config] SUPABASE_URL:", url.absoluteString)
        print("🧭 [Config] SUPABASE_ANON_KEY (prefix):", String(key.prefix(8)) + "…")
        #endif

        client = SupabaseClient(supabaseURL: url, supabaseKey: key)

        #if DEBUG
        print("✅ SupabaseManager: client ready")
        #endif
    }
}
