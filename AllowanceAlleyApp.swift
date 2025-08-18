import SwiftUI
import Supabase

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isSignedIn {
                    ChildrenListView()
                        .environmentObject(auth)
                } else {
                    EmailAuthView()
                        .environmentObject(auth)
                }
            }
            .onOpenURL { url in
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
