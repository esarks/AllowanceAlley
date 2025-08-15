import Foundation
import Supabase

// Optional convenience wrapper; use if you prefer calling here instead of directly in views.
enum SupabaseService {
    static var client: SupabaseClient { SupabaseManager.shared.client }

    static func session() async throws -> Session {
        if let s = try? await client.auth.session {
            return s
        }
        throw NSError(domain: "SupabaseService", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
    }
}
