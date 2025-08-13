import SwiftUI

struct RewardItem: Identifiable {
    let id = UUID()
    var name: String
    var cost: Int
}

struct RewardsView: View {
    @State private var rewards: [RewardItem] = [
        .init(name: "Extra Screen Time", cost: 50),
        .init(name: "Ice Cream", cost: 30),
        .init(name: "Movie Night Pick", cost: 40)
    ]

    var body: some View {
        NavigationStack {
            List(rewards) { reward in
                HStack {
                    Text(reward.name)
                    Spacer()
                    Text("\(reward.cost) pts").foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Rewards")
        }
    }
}

