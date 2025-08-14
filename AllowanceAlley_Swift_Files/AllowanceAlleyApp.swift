import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            FamilyHomeView()
                .environmentObject(auth)
                .onOpenURL { url in
                    Task { await auth.handleOpenURL(url) }
                }
        }
    }
}