import Foundation
import Supabase
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService(); private init() {}
    private let client = SupabaseManager.shared.client

    @Published var isSignedIn: Bool = false

    func loadSession() async {
        do { isSignedIn = (try await client.auth.session) != nil }
        catch { isSignedIn = false }
    }

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        isSignedIn = true
    }

    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
        isSignedIn = true
    }

    func signOut() async throws {
        try await client.auth.signOut()
        isSignedIn = false
    }
}
