import SwiftUI

struct EmailAuthView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        NavigationStack {
            Form {
                Section("Create account") {
                    TextField("Email", text: $auth.email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $auth.password)
                        .textContentType(.newPassword)
                    Button {
                        Task { await auth.signUp() }
                    } label: { auth.isLoading ? AnyView(ProgressView().eraseToAnyView())
                                              : AnyView(Text("Sign up").eraseToAnyView()) }
                    .disabled(auth.email.isEmpty || auth.password.isEmpty || auth.isLoading)
                }

                Section("Verify email (code)") {
                    TextField("6-digit code", text: $auth.code)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                    Button {
                        Task { await auth.verifyCode() }
                    } label: { Text("Verify") }
                    .disabled(auth.code.isEmpty || auth.isLoading)

                    if auth.isVerified {
                        Label("Email verified", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                    }
                }

                Section("Sign in") {
                    Button {
                        Task { await auth.signIn() }
                    } label: { Text("Sign in with email & password") }
                    .disabled(auth.email.isEmpty || auth.password.isEmpty || auth.isLoading)

                    if auth.isSignedIn {
                        Label("Signed in", systemImage: "person.fill.checkmark")
                            .foregroundStyle(.green)
                    }
                }

                if let err = auth.errorMessage, !err.isEmpty {
                    Section { Text(err).foregroundStyle(.red) }
                }

                if auth.isSignedIn {
                    Section {
                        Button(role: .destructive) {
                            Task { await auth.signOut() }
                        } label: { Text("Sign out") }
                    }
                }
            }
            .navigationTitle("Email Auth")
        }
        .onAppear { Task { await auth.bootstrap() } }
    }
}

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
