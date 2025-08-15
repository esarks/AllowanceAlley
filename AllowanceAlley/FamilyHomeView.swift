import SwiftUI

struct FamilyHomeView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        // Replace with your real content
        VStack(spacing: 16) {
            Text("Family").font(.title)
            if let email = auth.user?.email {
                Text("Signed in as \(email)")
            } else {
                NavigationLink("Go to Sign In") { SignInView() }
            }
        }
        .padding()
    }
}