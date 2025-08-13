import Foundation
import Supabase
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService(); private init() {}
    private let client = SupabaseManager.shared.client

    @Published var isSignedIn = false

    func loadSession() async {
        isSignedIn = (try? await client.auth.session) != nil
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
        isSignedIn = (try? await client.auth.session) != nil
    }

    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(email: email, password: password)
        isSignedIn = (try? await client.auth.session) != nil
    }

    func signOut() async throws {
        try await client.auth.signOut()
        isSignedIn = false
    }
}
