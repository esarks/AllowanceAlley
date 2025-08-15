import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FamilyHomeView()
            }
            .environmentObject(auth)             // inject high in the tree
            .onOpenURL { url in
                Task { await auth.handleOpenURL(url) }
            }
        }
    }
}
