import Foundation
import Supabase

enum AppConfig {
    static var url: URL {
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
        client = SupabaseClient(
            supabaseURL: AppConfig.url,
            supabaseKey: AppConfig.anonKey
        )
    }
}
