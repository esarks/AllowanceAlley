import SwiftUI

struct ApprovalsInboxView: View {
    @State private var vm: ApprovalsViewModel

    init(familyId: UUID) {
        _vm = State(initialValue: .init(repo: RewardsDI.makeRepo(), familyId: familyId))
    }

    var body: some View {
        NavigationStack {
            List {
                if !vm.pending.isEmpty {
                    Section("Pending") {
                        ForEach(vm.pending) { req in
                            RequestRow(req: req,
                                       onApprove: { Task { await vm.decide(req, approve: true) } },
                                       onReject: { Task { await vm.decide(req, approve: false) } })
                        }
                    }
                }
                if !vm.approved.isEmpty {
                    Section("Approved") { ForEach(vm.approved) { RequestRow(req: $0) } }
                }
                if !vm.rejected.isEmpty {
                    Section("Rejected") { ForEach(vm.rejected) { RequestRow(req: $0) } }
                }
            }
            .navigationTitle("Approvals")
            .task { await vm.load() }
        }
    }
}

private struct RequestRow: View {
    let req: RedemptionRequest
    var onApprove: (() -> Void)? = nil
    var onReject: (() -> Void)? = nil

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            VStack(alignment: .leading) {
                Text(req.reward.title).font(.headline)
                Text(req.status.rawValue.capitalized).font(.subheadline)
            }
            Spacer()
            if let onApprove, let onReject, req.status == .pending {
                HStack(spacing: 8) {
                    Button("Approve", action: onApprove).buttonStyle(.borderedProminent)
                    Button("Reject", role: .destructive, action: onReject).buttonStyle(.bordered)
                }
            }
        }
    }
}
