import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign in").font(.title.bold())

            TextField("Email", text: $auth.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $auth.password)
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Sign Up") { Task { await auth.signUp() } }
                    .buttonStyle(.borderedProminent)
                Button("Sign In") { Task { await auth.signIn() } }
                    .buttonStyle(.bordered)
            }

            HStack {
                TextField("Email code", text: $auth.code)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                Button("Verify") { Task { await auth.verifyCode() } }
            }

            if let msg = auth.errorMessage {
                Text(msg).foregroundStyle(.red)
            }
        }
        .padding()
    }
}