
import SwiftUI

/// Simple router that shows SignIn when no user, and Home when logged in.
struct RootView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        Group {
            if auth.user == nil {
                SignInView()
            } else {
                FamilyHomeView()
            }
        }
    }
}
