import Supabase
import Observation

@Observable final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let client = SupabaseManager.shared.client
    var session: Session?

    @MainActor
    func loadSession() async {
        session = try? await client.auth.session
    }

    @MainActor
    func signIn(email: String, password: String) async throws {
        let (s, _) = try await client.auth.signIn(email: email, password: password)
        session = s
    }

    @MainActor
    func signUp(email: String, password: String) async throws {
        let (s, _) = try await client.auth.signUp(email: email, password: password)
        session = s
    }

    @MainActor
    func signOut() async throws {
        try await client.auth.signOut()
        session = nil
    }
}
