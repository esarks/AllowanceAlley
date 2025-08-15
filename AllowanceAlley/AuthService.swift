import Foundation
import Combine
import Supabase

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    private let client = SupabaseManager.shared.client

    @Published var session: Session?
    @Published var user: User?
    @Published var errorMessage: String?

    // MARK: - Email + Password (legacy SDK you have)

    /// Sign up and have Supabase send a confirmation email that deep-links to the app.
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        do {
            // legacy API: `redirectTo:` exists and expects a URL
            guard let redirect = URL(string: "allowancealley://auth-callback") else {
                throw URLError(.badURL)
            }
            try await client.auth.signUp(
                email: email,
                password: password,
                redirectTo: redirect
            )
            #if DEBUG
            print("✉️ SignUp: confirmation email requested → \(redirect.absoluteString)")
            #endif
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// Legacy sign-in; then fetch the current session.
    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            try await client.auth.signIn(email: email, password: password)
            let s = try await client.auth.session   // non-optional on this SDK
            self.session = s
            self.user = s.user
            #if DEBUG
            print("🔑 SignIn ok →", user?.email ?? "<nil>")
            #endif
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signOut() async {
        errorMessage = nil
        do {
            try await client.auth.signOut()
            self.session = nil
            self.user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Handle confirm/magic-link callback (legacy)
    func handleOpenURL(_ url: URL) async {
        do {
            // legacy API returns a non-optional Session
            let s = try await client.auth.session(from: url)
            self.session = s
            self.user = s.user
            #if DEBUG
            print("🔐 Callback ok →", user?.email ?? "<nil>")
            #endif
        } catch {
            #if DEBUG
            print("🔐 Callback failed:", error.localizedDescription)
            #endif
            self.errorMessage = error.localizedDescription
        }
    }
}
