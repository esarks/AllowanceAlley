import Foundation

@MainActor
protocol RewardsRepository {
    func listRewards(familyId: UUID) async throws -> [Reward]
    func upsertReward(_ reward: Reward, familyId: UUID) async throws
    func archiveReward(_ rewardId: UUID, familyId: UUID) async throws

    func createRedemptionRequest(rewardId: UUID, childId: UUID) async throws -> RedemptionRequest
    func listRedemptionRequests(familyId: UUID, status: RedemptionStatus?) async throws -> [RedemptionRequest]
    func decide(requestId: UUID, approve: Bool, note: String?) async throws -> RedemptionRequest
}
