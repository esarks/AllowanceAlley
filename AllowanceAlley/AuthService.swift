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
    func signUp(email: String, password: String) async throws {
        errorMessage = nil
        do {
            guard let redirect = URL(string: "allowancealley://auth-callback") else {
                throw URLError(.badURL)
            }
            try await client.auth.signUp(
                email: email,
                password: password,
                redirectTo: redirect
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    func signIn(email: String, password: String) async throws {
        errorMessage = nil
        do {
            try await client.auth.signIn(email: email, password: password)
            let s = try await client.auth.session
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

    // MARK: - Handle confirm/magic-link callback (legacy)
    func handleOpenURL(_ url: URL) async {
        do {
            let s = try await client.auth.session(from: url)
            self.session = s
            self.user = s.user
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    // Add inside AuthService class
    func refreshSessionOnLaunch() async {
        errorMessage = nil
        do {
            let s = try await client.auth.session
            self.session = s
            self.user = s.user
        } catch {
            // No active session is normal on first run; don't surface as an error.
            self.session = nil
            self.user = nil
        }
    }
}
