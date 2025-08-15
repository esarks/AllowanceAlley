import SwiftUI

struct FamilyHomeView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        VStack(spacing: 16) {
            Text("Family").font(.title)

            if let email = auth.user?.email {
                Text("Signed in as \(email)")
                Button("Sign Out") { Task { await auth.signOut() } }
            } else {
                NavigationLink("Go to Sign In") { SignInView() }
            }
        }
        .padding()
        .navigationTitle("Home")
    }
}
