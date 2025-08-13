import Foundation
import Supabase
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    private init() {}

    private let client = SupabaseManager.shared.client

    @Published var isSignedIn: Bool = false

    func loadSession() async {
        // if a session exists, you're signed in
        isSignedIn = (try? await client.auth.session) != nil
    }

    func signIn(email: String, password: String) async throws {
        // OLD:
        // let response = try await client.auth.signIn(email: email, password: password)
        // isSignedIn = (response.session != nil)

        // NEW:
        try await client.auth.signIn(email: email, password: password)
        isSignedIn = (try? await client.auth.session) != nil
    }

    func signUp(email: String, password: String) async throws {
        // OLD:
        // let response = try await client.auth.signUp(email: email, password: password)
        // isSignedIn = (response.session != nil)

        // NEW:
        try await client.auth.signUp(email: email, password: password)
        isSignedIn = (try? await client.auth.session) != nil
    }


    func signOut() async throws {
        try await client.auth.signOut()
        isSignedIn = false
    }
}
