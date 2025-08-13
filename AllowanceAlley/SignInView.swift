import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Email", text: $email).textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                if let error { Text(error).foregroundStyle(.red) }
                Button("Sign In") {
                    Task {
                        do { try await auth.signIn(email: email, password: password) }
                        catch { self.error = error.localizedDescription }
                    }
                }
                Button("Sign Up") {
                    Task {
                        do { try await auth.signUp(email: email, password: password) }
                        catch { self.error = error.localizedDescription }
                    }
                }
            }
            .navigationTitle("AllowanceAlley")
        }
    }
}
