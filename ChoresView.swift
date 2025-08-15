import SwiftUI

private struct Chore: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var done: Bool = false
}

struct ChoresView: View {
    let familyId: UUID
    let childId: UUID?

    init(familyId: UUID? = nil, childId: UUID? = nil) {
        self.familyId = familyId ?? UUID()
        self.childId  = childId
    }

    @State private var chores: [Chore] = [
        .init(title: "Make bed"),
        .init(title: "Feed the dog"),
        .init(title: "Clean room"),
        .init(title: "Do homework")
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach($chores) { $chore in
                    HStack {
                        Text(chore.title)
                        Spacer()
                        Toggle("", isOn: $chore.done).labelsHidden()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { chore.done.toggle() }
                }
                .onDelete { chores.remove(atOffsets: $0) }
            }
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        chores.append(.init(title: "New chore \(chores.count + 1)"))
                    } label { Image(systemName: "plus") }
                }
            }
        }
    }
}