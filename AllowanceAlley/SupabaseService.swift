import Foundation

@MainActor
final class SupabaseService: ObservableObject {
  @Published var isSignedIn = true   // set true so the router hits .ready
  func session() async throws -> String? { isSignedIn ? "ok" : nil }
}
