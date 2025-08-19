import SwiftUI

struct ChildrenListView: View {
    @EnvironmentObject var auth: AuthService
    @StateObject private var svc = ChildService()
    @State private var showingAdd = false
    @State private var editing: Child?

    var body: some View {
        NavigationStack {
            List {
                ForEach(svc.children) { child in
                    Button { editing = child } label: {
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
                        for i in idx { await svc.delete(svc.children[i].id) } // ← no 'id:' label
                    }
                }
            }
            .navigationTitle("Children")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showingAdd) {
                ChildFormView(mode: .create) { name, birthdate, data in
                    Task { await svc.add(name: name, birthdate: birthdate, avatarData: data) }
                }
            }
            .sheet(item: $editing) { kid in
                ChildFormView(mode: .edit(existing: kid)) { name, birthdate, data in
                    Task {
                        var updated = kid
                        updated.name = name
                        updated.birthdate = birthdate
                        if let data = data {
                            await svc.uploadAvatar(for: updated, imageData: data)
                        } else {
                            await svc.update(updated)
                        }
                    }
                }
            }
            .overlay { if svc.isLoading { ProgressView() } }
            .task { await svc.load() }
            .alert("Error",
                   isPresented: Binding(get: { svc.errorMessage != nil },
                                        set: { _ in svc.errorMessage = nil })) {
                Button("OK", role: .cancel) {}
            } message: { Text(svc.errorMessage ?? "") }
        }
    }

    @ViewBuilder
    private func avatar(for child: Child) -> some View {
        let placeholder = Color.secondary.opacity(0.15)

        if let path = child.avatarUrl,
           let url = svc.publicURL(for: path) {
            if #available(iOS 15.0, *) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFill()
                        .frame(width: 44, height: 44)     // ← modifiers INSIDE the branch
                        .clipShape(Circle())
                } placeholder: {
                    placeholder
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                }
            } else {
                placeholder
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
        } else {
            placeholder
                .frame(width: 44, height: 44)
                .clipShape(Circle())
        }
    }

    private func computedAge(from birthdate: Date?) -> Int? {
        guard let b = birthdate else { return nil }
        return Calendar.current.dateComponents([.year], from: b, to: Date()).year
    }
}
