import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var svc = ChildService()

    @State private var showingAdd = false
    @State private var editing: Child? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(svc.children) { child in
                    Button {
                        // Open in EDIT mode for this child
                        editing = child
                    } label: {
                        HStack(spacing: 12) {
                            avatar(for: child)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(child.name).font(.headline)
                                if let age = computedAge(from: child.birthdate) {
                                    Text("\(age) yrs").foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { idx in
                    Task {
                        for i in idx { await svc.delete(id: svc.children[i].id) }
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
                }
            }
            .task { await svc.load() }
            // ADD sheet
            .sheet(isPresented: $showingAdd) {
                ChildFormView(
                    mode: .create,
                    onSave: { name, birthdate, avatarData in
                        // wrap the async call
                        Task { await svc.add(name: name, birthdate: birthdate, avatarData: avatarData) }
                    }
                )
                .presentationDetents([.large])
            }
            // EDIT sheet
            .sheet(item: $editing) { child in
                ChildFormView(
                    mode: .edit(existing: child),
                    onSave: { name, birthdate, avatarData in
                        Task {
                            var updated = child
                            updated.name = name
                            updated.birthdate = birthdate
                            if let data = avatarData {
                                await svc.uploadAvatar(for: updated, imageData: data)
                            } else {
                                await svc.update(updated)
                            }
                        }
                    }
                )
                .presentationDetents([.large])
            }
            // Error surface (optional)
            .alert("Error", isPresented: .constant(svc.errorMessage != nil), actions: {
                Button("OK") { svc.errorMessage = nil }
            }, message: {
                Text(svc.errorMessage ?? "")
            })
        }
    }

    // MARK: - Helpers

    private func computedAge(from date: Date?) -> Int? {
        guard let d = date else { return nil }
        let comps = Calendar.current.dateComponents([.year], from: d, to: Date())
        return comps.year
    }

    /// Small avatar bubble; shows placeholder if missing
    @ViewBuilder
    private func avatar(for child: Child) -> some View {
        if let path = child.avatarUrl,
           let url = ChildService().publicURL(for: path) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color.secondary.opacity(0.15)
                    }
                }
                .frame(width: 44, height: 44)      // <-- apply modifier to the view instance
                .clipShape(Circle())
            } else {
                Color.secondary.opacity(0.15)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
        } else {
            Color.secondary.opacity(0.15)
                .frame(width: 44, height: 44)
                .clipShape(Circle())
        }
    }
}
