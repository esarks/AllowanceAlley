import Foundation
import Supabase

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
        client = SupabaseClient(supabaseURL: AppConfig.url, supabaseKey: AppConfig.anonKey)
    }
}
