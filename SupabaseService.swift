import Foundation
import Combine

@MainActor
final class SupabaseService: ObservableObject {
    @Published var isSignedIn: Bool = true  // toggle for testing

    func session() async throws -> String? {
        return isSignedIn ? "ok" : nil
    }
}
