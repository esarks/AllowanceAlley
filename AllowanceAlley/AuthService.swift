
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
    // Compatible with older Supabase Swift API:
    // - signUp(email:password:)
    // - signIn(email:password:)
    // - session(from: URL)
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        do {
            // Older SDK does not accept emailRedirectTo in code; configure redirect in Dashboard.
            _ = try await client.auth.signUp(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            // Older SDK uses signIn(email:password:)
            let s = try await client.auth.signIn(email: email, password: password)
            self.session = s
            self.user = s.user
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

    // MARK: - Handle magic‑link / email confirmation callback
    func handleOpenURL(_ url: URL) async {
        do {
            // Older SDK parses the callback URL into a Session
            let s = try await client.auth.session(from: url)
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
