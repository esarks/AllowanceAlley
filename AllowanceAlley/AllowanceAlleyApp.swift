
import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .onOpenURL { url in
                    // Handle allowancealley://auth-callback
                    Task { await auth.handleOpenURL(url) }
                }
        }
    }
}
