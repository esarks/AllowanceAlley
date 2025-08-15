import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FamilyHomeView()
                    .toolbar { ToolbarItem(placement: .principal) { Text("AllowanceAlley") } }
            }
            .environmentObject(auth)
            .task { await auth.refreshSessionOnLaunch() }   // ← reflect state on launch
            .onOpenURL { url in
                Task { await auth.handleOpenURL(url) }
            }
        }
    }
}
