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
                    Button {
                        editing = child
                        showingAdd = true
                    } label: {
                        HStack(spacing: 12) {
                            avatar(for: child)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(child.name).font(.headline)
                                if let age = computedAge(from: child.birthdate) {
                                    Text("\(age) yrs").foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    Task {
                        for idx in indexSet {
                            await svc.delete(id: svc.children[idx].id)
                        }
                    }
                }
            }
            .overlay {
                if svc.isLoading { ProgressView() }
            }
            .navigationTitle("Children")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editing = nil
                        showingAdd = true
                    } label: { Image(systemName: "plus") }
                }
            }
            .task { await svc.load() }
            .sheet(isPresented: $showingAdd) {
                ChildFormView(
                    mode: editing == nil ? .create : .edit(existing: editing!),
                    onSave: { name, birth, avatarData in
                        Task {
                            if let child = editing {
                                var updated = child
                                updated.name = name
                                updated.birthdate = birth
                                if let data = avatarData {
                                    await svc.uploadAvatar(for: updated, imageData: data)
                                } else {
                                    await svc.update(updated)
                                }
                            } else {
                                await svc.add(name: name, birthdate: birth, avatarData: avatarData)
                            }
                        }
                    }
                )
            }
        }
        .environmentObject(auth)
        .alert(item: Binding(
            get: { svc.errorMessage.map { LocalizedErrorBox(message: $0) } },
            set: { _ in svc.errorMessage = nil })
        ) { box in
            Alert(title: Text("Error"), message: Text(box.message), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Small helpers

    private func avatar(for child: Child) -> some View {
        Group {
            if let path = child.avatarUrl,
               let url = ChildService().publicURL(for: path) {
                if #available(iOS 15.0, *) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.secondary.opacity(0.15)
                        case .failure:
                            Color.secondary.opacity(0.15)
                        case .success(let img):
                            img.resizable().scaledToFill()
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
        }
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private func computedAge(from date: Date?) -> Int? {
        guard let d = date else { return nil }
        let years = Calendar.current.dateComponents([.year], from: d, to: Date()).year
        return years
    }
}

private struct LocalizedErrorBox: Identifiable {
    let id = UUID()
    let message: String
}
