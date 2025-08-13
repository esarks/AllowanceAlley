import Supabase
import Foundation

enum AppConfig {
    static var url: URL {
        // Reads from Info.plist (or xcconfig via build settings)
        let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        return URL(string: s ?? ProcessInfo.processInfo.environment["SUPABASE_URL"]!)!
    }
    static var anonKey: String {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String
        ?? ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"]!
    }
}

final class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    private init() {
        client = SupabaseClient(supabaseURL: AppConfig.url, supabaseKey: AppConfig.anonKey)
    }
}

