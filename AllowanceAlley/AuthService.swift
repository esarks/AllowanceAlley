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

    // MARK: - Email + Password (Supabase Swift 2.x)
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
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            let result = try await client.auth.signInWithPassword(
                email: email, password: password
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

    // MARK: - Deep‑link callback (2.x)
    func handleOpenURL(_ url: URL) async {
        do {
            try await client.auth.exchangeCodeFromCallbackURL(url)
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
            #if DEBUG
            print("🔐 Auth callback OK, user:", user?.email ?? "<nil>")
            #endif
        } catch {
            self.errorMessage = error.localizedDescription
            #if DEBUG
            print("🔐 Auth callback failed:", error.localizedDescription)
            #endif
        }
    }
}
