import Foundation
import Combine

@MainActor
final class SupabaseService: ObservableObject {
    @Published var isSignedIn: Bool = true // set false to test unauth state

    // Replace with your real Supabase session lookup
    func session() async throws -> String? {
        return isSignedIn ? "ok" : nil
    }
}
