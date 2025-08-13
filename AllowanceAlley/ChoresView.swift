import SwiftUI

struct ChoreItem: Identifiable {
    let id = UUID()
    var title: String
    var points: Int
    var done: Bool = false
}

struct ChoresView: View {
    @State private var chores: [ChoreItem] = [
        .init(title: "Make Bed", points: 5),
        .init(title: "Dishes", points: 10),
        .init(title: "Feed Pet", points: 7)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(chores.indices, id: \.self) { i in
                    HStack {
                        Image(systemName: chores[i].done ? "checkmark.circle.fill" : "circle")
                            .onTapGesture { chores[i].done.toggle() }
                        VStack(alignment: .leading) {
                            Text(chores[i].title)
                            Text("\(chores[i].points) pts").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Chores")
        }
    }
}
