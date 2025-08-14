import SwiftUI

struct FamilyHomeView: View {
    @EnvironmentObject private var auth: AuthService
    private let service = FamilyService()

    @State private var familyId: UUID?
    @State private var members: [MemberDTO] = []
    @State private var showAddChild = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
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
                    Button("Sign Out") { Task { try? await auth.signOut() } }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddChild = true } label: { Label("Add", systemImage: "plus") }
                }
            }
            .task { await load() }
            .refreshable { await load() }
            .sheet(isPresented: $showAddChild) {
                AddChildSheet(familyId: familyId, service: service) {
                    await load()
                }
            }
        }
    }

    @MainActor
    private func load() async {
        do {
            let id = try await service.getOrCreateMyFamily()
            familyId = id
            members = try await service.getMembers(familyId: id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct AddChildSheet: View {
    let familyId: UUID?
    let service: FamilyService
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
                            guard let familyId, !name.isEmpty else { return }
                            let intAge = Int(age)
                            try? await service.addChild(familyId: familyId, name: name, age: intAge)
                            await onAdded()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
