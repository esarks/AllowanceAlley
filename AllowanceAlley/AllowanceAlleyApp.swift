import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            // Replace with your true root view if different
            FamilyHomeView()
                .environmentObject(auth)
                .onOpenURL { url in
                    Task { await auth.handleOpenURL(url) }
                }
        }
    }
}