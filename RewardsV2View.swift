
import SwiftUI

struct RewardsV2View: View {
    @EnvironmentObject private var ledger: AALedgerStore

    // Demo child id — replace with your selected child when wiring.
    private let childId: UUID = UUID()

    @State private var rewards = AARewardsCatalog.demo
    @State private var showAlert = false
    @State private var alertText = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Points: \(ledger.totalPoints(for: childId))") { EmptyView() }

                ForEach(rewards) { reward in
                    HStack {
                        Text(reward.name)
                        Spacer()
                        Text("\(reward.cost) pts")
                        Button("Redeem") {
                            let ok = ledger.redeem(reward.cost, note: reward.name, childId: childId)
                            alertText = ok ? "Redeemed \(reward.name)" : "Not enough points"
                            showAlert = true
                        }
                        .buttonStyle(.bordered)
                        .disabled(ledger.totalPoints(for: childId) < reward.cost)
                    }
                }
            }
            .navigationTitle("Rewards (V2)")
            .alert(alertText, isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}
