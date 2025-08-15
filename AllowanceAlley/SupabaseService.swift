import Foundation
import Supabase

final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let urlString = info["SUPABASE_URL"] as? String ?? ""
        let anonKey   = info["SUPABASE_ANON_KEY"] as? String ?? ""

        guard let url = URL(string: urlString), !anonKey.isEmpty else {
            fatalError("Missing or invalid SUPABASE_URL / SUPABASE_ANON_KEY in Info.plist")
        }
        client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
    }
}
