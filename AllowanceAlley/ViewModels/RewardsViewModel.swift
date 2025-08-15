import Foundation
import Observation

@MainActor
@Observable
final class RewardsViewModel {
    var rewards: [Reward] = []
    var loading = false
    var error: String?

    private let repo: any RewardsRepository
    private let familyId: UUID
    private let role: Role
    private let childId: UUID?

    init(repo: any RewardsRepository, familyId: UUID, role: Role, childId: UUID? = nil) {
        self.repo = repo
        self.familyId = familyId
        self.role = role
        self.childId = childId
    }

    func load() async {
        loading = true; error = nil
        do {
            rewards = try await repo.listRewards(familyId: familyId)
        } catch {
            self.error = error.localizedDescription
        }
        loading = false
    }

    func request(_ reward: Reward) async {
        guard role == .child, let childId else { return }
        do {
            _ = try await repo.createRedemptionRequest(rewardId: reward.id, childId: childId)
        } catch {
            self.error = error.localizedDescription
        }
    }

    func save(_ reward: Reward) async {
        guard role == .parent else { return }
        do { try await repo.upsertReward(reward, familyId: familyId) }
        catch { self.error = error.localizedDescription }
    }

    func archive(_ reward: Reward) async {
        guard role == .parent else { return }
        do { try await repo.archiveReward(reward.id, familyId: familyId) }
        catch { self.error = error.localizedDescription }
    }
}
