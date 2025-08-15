import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var localError: String?

    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Password", text: $password)
            }

            if let e = localError ?? auth.errorMessage {
                Text(e).foregroundStyle(.red)
            }

            Button("Sign In") {
                Task {
                    do {
                        try await auth.signIn(email: email, password: password)
                        localError = nil
                    } catch { localError = error.localizedDescription }
                }
            }

            Button("Sign Up") {
                Task {
                    do {
                        try await auth.signUp(email: email, password: password)
                        localError = "Check your email to confirm, then return here to Sign In."
                    } catch { localError = error.localizedDescription }
                }
            }
        }
        .navigationTitle("Sign In")
    }
}
