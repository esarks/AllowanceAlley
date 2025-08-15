import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FamilyHomeView()
            }
            // Inject ONCE, as high as possible, so all descendants (including pushed views) inherit it.
            .environmentObject(auth)
            .onOpenURL { url in
                Task { await auth.handleOpenURL(url) }
            }
        }
    }
}
