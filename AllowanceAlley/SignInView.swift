import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var auth: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $email).textInputAutocapitalization(.never)
                SecureField("Password", text: $password)

                if let errorMessage { Text(errorMessage).foregroundStyle(.red) }

                Button("Sign In") {
                    Task {
                        do { try await auth.signIn(email: email, password: password); errorMessage = nil }
                        catch { errorMessage = error.localizedDescription }
                    }
                }
                Button("Sign Up") {
                    Task {
                        do { try await auth.signUp(email: email, password: password); errorMessage = nil }
                        catch { errorMessage = error.localizedDescription }
                    }
                }
            }
            .navigationTitle("AllowanceAlley")
        }
    }
}
