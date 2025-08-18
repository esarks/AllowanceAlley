import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var auth = AuthService()

    var body: some Scene {
        WindowGroup {
            EmailAuthView()
                .environmentObject(auth)
        }
    }
}
