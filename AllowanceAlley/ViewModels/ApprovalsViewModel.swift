import Foundation
import Observation

@MainActor
@Observable
final class ApprovalsViewModel {
    var pending: [RedemptionRequest] = []
    var approved: [RedemptionRequest] = []
    var rejected: [RedemptionRequest] = []
    var loading = false
    var error: String?

    private let repo: any RewardsRepository
    private let familyId: UUID

    init(repo: any RewardsRepository, familyId: UUID) {
        self.repo = repo
        self.familyId = familyId
    }

    func load() async {
        loading = true; error = nil
        do {
            pending = try await repo.listRedemptionRequests(familyId: familyId, status: .pending)
            approved = try await repo.listRedemptionRequests(familyId: familyId, status: .approved)
            rejected = try await repo.listRedemptionRequests(familyId: familyId, status: .rejected)
        } catch {
            self.error = error.localizedDescription
        }
        loading = false
    }

    func decide(_ request: RedemptionRequest, approve: Bool, note: String? = nil) async {
        do {
            _ = try await repo.decide(requestId: request.id, approve: approve, note: note)
            await load()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
