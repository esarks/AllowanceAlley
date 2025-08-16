import SwiftUI

struct FamilyHomeView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        VStack(spacing: 20) {
            if let email = auth.user?.email {
                // Signed in
                Image(systemName: "person.crop.circle.badge.checkmark").font(.system(size: 50))
                Text("Signed in as").foregroundStyle(.secondary)
                Text(email).font(.title3).bold()

                Button("Sign Out") {
                    Task { await auth.signOut() }
                }
                .buttonStyle(.borderedProminent)

            } else {
                // Signed out
                Image(systemName: "person.crop.circle").font(.system(size: 50))
                Text("You’re not signed in yet.").foregroundStyle(.secondary)

                NavigationLink("Go to Sign In") {
                    SignInView()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }

            // Debug/status line (safe to keep or remove later)
            if let e = auth.errorMessage, !e.isEmpty {
                Text(e).foregroundStyle(.red).font(.footnote).padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
