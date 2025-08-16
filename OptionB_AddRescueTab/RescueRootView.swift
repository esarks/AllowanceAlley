import SwiftUI

final class RescueLedger: ObservableObject {
    @Published var points: Int = 10
    func earn(_ p: Int) { points += p }
    func redeem(_ p: Int) -> Bool {
        guard points >= p else { return false }
        points -= p; return true
    }
}

struct RescueChore: Identifiable { var id = UUID(); var title: String; var pts: Int; var done = false }
struct RescueReward: Identifiable { var id = UUID(); var name: String; var cost: Int }

struct RescueBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lifepreserver")
            Text("Rescue UI (standalone)")
        }
        .font(.caption2).bold()
        .padding(6)
        .background(.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct RescueChoresView: View {
    @ObservedObject var ledger: RescueLedger
    @State private var chores: [RescueChore] = [
        .init(title: "Make bed", pts: 2),
        .init(title: "Feed the dog", pts: 1),
        .init(title: "Clean room", pts: 3),
        .init(title: "Do homework", pts: 4)
    ]

    var body: some View {
        NavigationStack {
            List {
                Section { RescueBanner() }
                ForEach(chores.indices, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(chores[i].title)
                            Text("\(chores[i].pts) pts").font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(get: { chores[i].done }, set: { newVal in
                            if newVal && !chores[i].done { ledger.earn(chores[i].pts) }
                            chores[i].done = newVal
                        })).labelsHidden()
                    }
                }
                .onDelete { chores.remove(atOffsets: $0) }
            }
            .navigationTitle("Chores (Rescue)")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { chores.append(.init(title: "New chore \(chores.count+1)", pts: 1)) } label { Image(systemName: "plus") }
                }
            }
        }
    }
}

struct RescueRewardsView: View {
    @ObservedObject var ledger: RescueLedger
    @State private var rewards: [RescueReward] = [
        .init(name: "Extra screen time", cost: 5),
        .init(name: "Pick dessert", cost: 3),
        .init(name: "Stay up late", cost: 7)
    ]
    @State private var alert: String? = nil

    var body: some View {
        NavigationStack {
            List {
                Section { RescueBanner() }
                Section("Points: \(ledger.points)") { EmptyView() }
                ForEach(rewards) { r in
                    HStack {
                        Text(r.name)
                        Spacer()
                        Text("\(r.cost) pts")
                        Button("Redeem") {
                            alert = ledger.redeem(r.cost) ? "Redeemed \(r.name)" : "Not enough points"
                        }.buttonStyle(.bordered).disabled(ledger.points < r.cost)
                    }
                }
            }
            .navigationTitle("Rewards (Rescue)")
            .alert(alert ?? "", isPresented: Binding(get: { alert != nil }, set: { _ in alert = nil })) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

struct RescueDashboardView: View {
    @ObservedObject var ledger: RescueLedger
    var body: some View {
        NavigationStack {
            List {
                Section { RescueBanner() }
                Section("Overview") {
                    HStack { Text("Total Points"); Spacer(); Text("\(ledger.points)") }
                    NavigationLink("Go to Chores") { RescueChoresView(ledger: ledger) }
                    NavigationLink("Go to Rewards") { RescueRewardsView(ledger: ledger) }
                }
            }
            .navigationTitle("Dashboard (Rescue)")
        }
    }
}

public struct RescueRootView: View {
    @StateObject private var ledger = RescueLedger()
    public init() {}
    public var body: some View {
        TabView {
            RescueDashboardView(ledger: ledger)
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }
            RescueChoresView(ledger: ledger)
                .tabItem { Label("Chores", systemImage: "checkmark.circle") }
            RescueRewardsView(ledger: ledger)
                .tabItem { Label("Rewards", systemImage: "gift") }
        }
    }
}
