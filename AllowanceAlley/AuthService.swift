import Foundation
import Supabase

final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let client = SupabaseManager.shared.client
    private let redirectURL = URL(string: "allowancealley://auth-callback")!

    // MARK: - Sign Up (email + password)
    // Supabase Swift 2.x signature:
    // signUp(email: String, password: String, data: [String:Any]? = nil, redirectTo: URL? = nil, captchaToken: String? = nil)
    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(
            email: email,
            password: password,
            data: nil,
            redirectTo: redirectURL,
            captchaToken: nil
        )
        // A verification email is sent automatically when "Confirm email" is ON in your project.
    }

    // MARK: - Sign In (email + password)
    // Supabase Swift 2.x signature:
    // signIn(email: String, password: String)
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(
            email: email,
            password: password
        )
        // If the user is confirmed, this returns a session.
        // If not confirmed, they’ll confirm via the email link (which opens your app via the URL scheme).
    }

    // MARK: - Helpers
    func currentUser() async throws -> User? {
        try await client.auth.session.user
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
