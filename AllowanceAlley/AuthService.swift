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

    // MARK: - Email + Password (2.x API)

    /// Sign up and have Supabase email a confirmation link that deep-links back into the app.
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        do {
            let options = SignUpOptions(
                emailRedirectTo: URL(string: "allowancealley://auth-callback")
            )
            try await client.auth.signUp(
                email: email,
                password: password,
                options: options
            )
            #if DEBUG
            print("✉️ SignUp: confirmation email requested (deep link set).")
            #endif
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// Sign in with email/password (works immediately if email already confirmed).
    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            let result = try await client.auth.signInWithPassword(
                email: email,
                password: password
            )
            self.session = result.session
            self.user = result.user
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

    // MARK: - Handle confirm / magic-link callback (2.x API)
    func handleOpenURL(_ url: URL) async {
        do {
            try await client.auth.exchangeCodeFromCallbackURL(url)
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
            #if DEBUG
            print("🔐 Callback OK →", user?.email ?? "<nil>")
            #endif
        } catch {
            self.errorMessage = error.localizedDescription
            #if DEBUG
            print("🔐 Callback failed:", error.localizedDescription)
            #endif
        }
    }
}
