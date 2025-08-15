import SwiftUI

private struct Reward: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var cost: Int
}

struct RewardsView: View {
    let familyId: UUID
    let childId: UUID?

    init(familyId: UUID? = nil, childId: UUID? = nil) {
        self.familyId = familyId ?? UUID()
        self.childId  = childId
    }

    @State private var points = 10
    @State private var rewards: [Reward] = [
        .init(name: "Extra screen time", cost: 5),
        .init(name: "Pick dessert",     cost: 3),
        .init(name: "Stay up late",     cost: 7)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Points: \(points)") { EmptyView() }
                ForEach(rewards) { reward in
                    HStack {
                        Text(reward.name)
                        Spacer()
                        Text("\(reward.cost) pts")
                        Button("Redeem") {
                            if points >= reward.cost { points -= reward.cost }
                        }
                        .buttonStyle(.bordered)
                        .disabled(points < reward.cost)
                    }
                }
            }
            .navigationTitle("Rewards")
        }
    }
}