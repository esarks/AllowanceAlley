import Foundation

struct Child: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var age: Int
    var points: Int = 0
}

final class FamilyStore: ObservableObject {
    @Published var familyName: String = "Marshall"
    @Published var children: [Child] = [
        Child(name: "Avery", age: 10, points: 25),
        Child(name: "Liam",  age: 8,  points: 15)
    ]

    var totalPoints: Int {
        children.map { $0.points }.reduce(0, +)
    }

    func addChild(name: String, age: Int) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        children.append(Child(name: name, age: age))
    }

    func awardPoints(to childID: UUID, amount: Int) {
        guard amount != 0 else { return }
        if let idx = children.firstIndex(where: { $0.id == childID }) {
            children[idx].points = max(0, children[idx].points + amount)
        }
    }
}
