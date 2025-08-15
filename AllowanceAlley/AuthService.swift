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

    // MARK: - Email + Password

    /// Sends a confirmation email using your deep link.
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        do {
            try await client.auth.signUp(
                email: email,
                password: password,
                data: nil,
                captchaToken: nil,
                emailRedirectTo: URL(string: "allowancealley://auth-callback")
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// Returns a session immediately if the account is already confirmed.
    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            let result = try await client.auth.signInWithPassword(
                email: email,
                password: password
            )
            self.session = result.session
            self.user = result.user
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

    // MARK: - Deep link handler for confirm/magic links
    func handleOpenURL(_ url: URL) async {
        do {
            try await client.auth.exchangeCodeFromCallbackURL(url)
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
            #if DEBUG
            print("🔐 Auth: callback ok, user:", user?.email ?? "<nil>")
            #endif
        } catch {
            #if DEBUG
            print("🔐 Auth: callback failed:", error.localizedDescription)
            #endif
            self.errorMessage = error.localizedDescription
        }
    }
}
