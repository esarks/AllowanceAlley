import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @State private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .task { await auth.loadSession() }
                .environment(auth)
        }
    }
}

struct RootView: View {
    @Environment(AuthService.self) private var auth
    var body: some View {
        Group {
            if auth.session == nil {
                SignInView()
            } else {
                FamilyHomeView()
            }
        }
    }
}
