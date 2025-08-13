import SwiftUI

struct FamilyHomeView: View {
    @Environment(AuthService.self) private var auth
    private let service = FamilyService()

    @State private var familyId: UUID?
    @State private var members: [MemberDTO] = []
    @State private var showAddChild = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                if let error { Text(error).foregroundStyle(.red) }
                Section("Children") {
                    ForEach(members.filter { $0.role == "child" }) { m in
                        HStack {
                            Text(m.child_name ?? "Child")
                            Spacer()
                            if let age = m.age { Text("Age \(age)").foregroundStyle(.secondary) }
                        }
                    }
                }
            }
            .navigationTitle("Family")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out") {
                        Task { try? await auth.signOut() }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddChild = true } label: { Label("Add", systemImage: "plus") }
                }
            }
            .task {
                await load()
            }
            .refreshable { await load() }
            .sheet(isPresented: $showAddChild) {
                AddChildSheet(familyId: familyId, onAdded: { await load() })
            }
        }
    }

    @MainActor
    private func load() async {
        do {
            let id = try await service.getOrCreateMyFamily()
            familyId = id
            members = try await service.members(familyId: id)
            error = nil
        } catch {
            error = error.localizedDescription
        }
    }
}

struct AddChildSheet: View {
    let familyId: UUID?
    var onAdded: @Sendable () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var age = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Child name", text: $name)
                TextField("Age", text: $age).keyboardType(.numberPad)
            }
            .navigationTitle("Add Child")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task {
                            guard let familyId else { return }
                            try? await FamilyService().addChild(
                                familyId: familyId,
                                name: name,
                                age: Int(age)
                            )
                            await onAdded()
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || familyId == nil)
                }
            }
        }
    }
}

