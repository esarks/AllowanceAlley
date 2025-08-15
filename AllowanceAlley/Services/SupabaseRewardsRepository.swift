import Foundation

/// Stub: wire Supabase client and implement the calls once your schema is ready.
@MainActor
final class SupabaseRewardsRepository: RewardsRepository {
    struct NotImplemented: LocalizedError { var errorDescription: String? { "Supabase repo not yet implemented." } }

    func listRewards(familyId: UUID) async throws -> [Reward] { throw NotImplemented() }
    func upsertReward(_ reward: Reward, familyId: UUID) async throws { throw NotImplemented() }
    func archiveReward(_ rewardId: UUID, familyId: UUID) async throws { throw NotImplemented() }

    func createRedemptionRequest(rewardId: UUID, childId: UUID) async throws -> RedemptionRequest { throw NotImplemented() }
    func listRedemptionRequests(familyId: UUID, status: RedemptionStatus?) async throws -> [RedemptionRequest] { throw NotImplemented() }
    func decide(requestId: UUID, approve: Bool, note: String?) async throws -> RedemptionRequest { throw NotImplemented() }
}
