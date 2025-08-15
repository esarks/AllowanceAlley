import SwiftUI
import Supabase

struct SetupFamilyView: View {
    @State private var busy = false
    @State private var error: String?
    private let client: SupabaseClient = SupabaseManager.shared.client
    let onFinished: (UserContext) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Let’s set up your family").font(.title2).bold()
            Text("Create your first family to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            if let error { Text(error).foregroundStyle(.red).font(.footnote) }

            Button(busy ? "Creating…" : "Create Family") {
                Task { await createFamily() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(busy)
        }
        .padding()
    }

    private func createFamily() async {
        busy = true; error = nil
        do {
            guard let session = try? await client.auth.session else {
                throw NSError(domain: "SetupFamily", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not signed in"])
            }
            let userId: UUID = session.user.id

            struct NewFamily: Encodable { let name: String; let owner_id: UUID }
            struct Created: Decodable { let id: UUID }

            let created: [Created] = try await client.database
                .from("families")
                .insert(NewFamily(name: "My Family", owner_id: userId))
                .select("id")
                .limit(1)
                .execute()
                .value

            guard let fam = created.first else {
                throw NSError(domain: "SetupFamily", code: 500, userInfo: [NSLocalizedDescriptionKey: "Family creation failed"])
            }

            let ctx = UserContext(familyId: fam.id, role: "parent", childUserId: nil)
            onFinished(ctx)
        } catch {
            self.error = error.localizedDescription
        }
        busy = false
    }
}
