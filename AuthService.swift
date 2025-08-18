import Foundation
import Combine
import Supabase

@MainActor
final class AuthService: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var code: String = ""           // 6-digit email code for verification
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isVerified: Bool = false
    @Published var isSignedIn: Bool = false

    private let client = SupabaseManager.shared.client

    // Refresh session/user on app start
    func bootstrap() async {
        errorMessage = nil
        do {
            // user() throws if not authenticated
            _ = try await client.auth.user()
            self.isSignedIn = true
        } catch {
            self.isSignedIn = false
        }
    }

    func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await client.auth.signUp(email: email, password: password)
            // Wait for user to enter the emailed OTP code
            self.isVerified = false
        } catch {
            self.errorMessage = friendly(error)
        }
    }

    func verifyCode() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await client.auth.verifyOTP(
                email: email,
                token: code,
                type: .signup
            )
            self.isVerified = true

            // Confirm we’re authenticated now
            _ = try await client.auth.user()
            self.isSignedIn = true
        } catch {
            self.errorMessage = friendly(error)
            self.isSignedIn = false
        }
    }

    func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            _ = try await client.auth.signIn(email: email, password: password)
            // Double-check we have a user
            _ = try await client.auth.user()
            self.isSignedIn = true
        } catch {
            self.errorMessage = friendly(error)
            self.isSignedIn = false
        }
    }

    func signOut() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            try await client.auth.signOut()
            self.isSignedIn = false
            self.isVerified = false
            self.code = ""
            self.password = ""
        } catch {
            self.errorMessage = friendly(error)
        }
    }

    private func friendly(_ error: Error) -> String {
        (error as NSError).localizedDescription
    }
}
