
import SwiftUI

struct FamilyHomeView: View {
    @EnvironmentObject private var auth: AuthService

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Family Home")
                    .font(.title2)

                if let email = auth.user?.email {
                    Text("Signed in as: \(email)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Button("Sign Out") {
                    Task { await auth.signOut() }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("AllowanceAlley")
        }
    }
}
