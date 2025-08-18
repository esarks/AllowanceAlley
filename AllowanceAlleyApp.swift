import SwiftUI
import Supabase

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            EmailAuthView()          // <- show the auth screen
                .environmentObject(auth)
                .onOpenURL { url in   // handle magic-link callbacks
                    Task {
                        do {
                            try await SupabaseManager.shared.client.auth.session(from: url)
                            auth.isSignedIn = true
                        } catch {
                            auth.errorMessage = (error as NSError).localizedDescription
                        }
                    }
                }
        }
    }
}
