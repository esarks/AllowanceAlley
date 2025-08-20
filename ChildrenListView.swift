import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var svc = ChildService()

    // Add vs Edit routing state
    @State private var showingAdd = false
    @State private var editing: Child? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(svc.children) { child in
                    Button {
                        editing = child   // <-- opens edit sheet now
                    } label: {
                        HStack(spacing: 12) {
                            avatar(for: child)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(child.name).font(.headline)
                                if let age = computedAge(from: child.birthdate) {
                                    Text("\(age) yrs")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("ChildRow_\(child.id.uuidString)")
                }
                .onDelete { indexSet in
                    Task {
                        for idx in indexSet {
                            let victim = svc.children[idx]
                            await svc.delete(id: victim.id)
                        }
                    }
                }
            }
            .navigationTitle("Children")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("AddChildButton")
                }
            }
            .task {
                await svc.load()
            }
            .alert("Error", isPresented: Binding(get: { svc.errorMessage != nil },
                                                 set: { _ in svc.errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(svc.errorMessage ?? "")
            }
            // ADD
            .sheet(isPresented: $showingAdd) {
                ChildFormView(
                    mode: .create,
                    onSave: { name, birthdate, avatarData in
                        await svc.add(name: name, birthdate: birthdate, avatarData: avatarData)
                    }
                )
            }
            // EDIT
            .sheet(item: $editing) { child in
                ChildFormView(
                    mode: .edit(existing: child),
                    onSave: { name, birthdate, avatarData in
                        // Update basic fields
                        var updated = child
                        updated.name = name
                        updated.birthdate = birthdate
                        await svc.update(updated)

                        // Optional new avatar
                        if let data = avatarData {
                            await svc.uploadAvatar(for: updated, imageData: data)
                        }
                    }
                )
            }
        }
    }

    // MARK: - UI bits

    @ViewBuilder
    private func avatar(for child: Child) -> some View {
        if let path = child.avatarUrl,
           let url = svc.publicURL(for: path) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.secondary.opacity(0.15)
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Color.secondary.opacity(0.15)
                    @unknown default:
                        Color.secondary.opacity(0.15)
                    }
                }
            } else {
                Color.secondary.opacity(0.15)
            }
        } else {
            Color.secondary.opacity(0.15)
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private func computedAge(from date: Date?) -> Int? {
        guard let d = date else { return nil }
        let comps = Calendar.current.dateComponents([.year], from: d, to: Date())
        return comps.year
    }
}
