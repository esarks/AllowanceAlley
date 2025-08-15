import SwiftUI
import Supabase

struct SetupFamilyView: View {
    let session: Session
    let onCreated: (UserContext) -> Void
    @State private var name: String = "My Family"
    @State private var creating = false
    @State private var error: String?
    let client: SupabaseClient = SupabaseManager.shared.client

    var body: some View {
        NavigationStack {
            Form {
                Section("Create your family") {
                    TextField("Family name", text: $name)
                    if let error { Text(error).foregroundStyle(.red) }
                    Button {
                        Task { await create() }
                    } label: {
                        if creating { ProgressView() } else { Text("Create Family") }
                    }
                    .disabled(creating || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Welcome")
        }
    }

    private func create() async {
        creating = true; error = nil
        do {
            let ctx = try await SessionManager.createFamily(using: client, session: session, name: name)
            onCreated(ctx)
        } catch {
            self.error = error.localizedDescription
        }
        creating = false
    }
}
