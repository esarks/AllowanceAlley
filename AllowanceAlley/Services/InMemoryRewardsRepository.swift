import Foundation

@MainActor
final class InMemoryRewardsRepository: RewardsRepository {
    private var rewards: [UUID: [Reward]] = [:] // familyId -> rewards
    private var requests: [UUID: [RedemptionRequest]] = [:] // familyId -> requests

    func listRewards(familyId: UUID) async throws -> [Reward] {
        rewards[familyId] ?? sampleRewards()
    }

    func upsertReward(_ reward: Reward, familyId: UUID) async throws {
        var list = rewards[familyId] ?? []
        if let idx = list.firstIndex(where: { $0.id == reward.id }) {
            list[idx] = reward
        } else {
            list.append(reward)
        }
        rewards[familyId] = list
    }

    func archiveReward(_ rewardId: UUID, familyId: UUID) async throws {
        var list = rewards[familyId] ?? []
        list.removeAll { $0.id == rewardId }
        rewards[familyId] = list
    }

    func createRedemptionRequest(rewardId: UUID, childId: UUID) async throws -> RedemptionRequest {
        guard let reward = (rewards.values.flatMap { $0 }).first(where: { $0.id == rewardId }) ?? sampleRewards().first(where: { $0.id == rewardId }) else {
            throw NSError(domain: "InMemoryRewardsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reward not found"])
        }
        var req = RedemptionRequest(reward: reward, childId: childId, note: nil, status: .pending, createdAt: .init(), decidedAt: nil)
        let familyId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")! // sample family
        var list = requests[familyId] ?? []
        list.append(req)
        requests[familyId] = list
        return req
    }

    func listRedemptionRequests(familyId: UUID, status: RedemptionStatus?) async throws -> [RedemptionRequest] {
        let all = requests[familyId] ?? []
        if let status { return all.filter { $0.status == status } }
        return all
    }

    func decide(requestId: UUID, approve: Bool, note: String?) async throws -> RedemptionRequest {
        let familyId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        var list = requests[familyId] ?? []
        guard let idx = list.firstIndex(where: { $0.id == requestId }) else {
            throw NSError(domain: "InMemoryRewardsRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Request not found"])
        }
        var updated = list[idx]
        updated.status = approve ? .approved : .rejected
        updated.decidedAt = .init()
        updated.note = note
        list[idx] = updated
        requests[familyId] = list
        return updated
    }

    private func sampleRewards() -> [Reward] {
        [
            Reward(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, title: "Movie Night", details: "Pick the family movie", costPoints: 50),
            Reward(id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, title: "Ice Cream Trip", details: "One scoop at your favorite shop", costPoints: 75),
            Reward(id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, title: "Extra Screen Time", details: "30 bonus minutes", costPoints: 30),
        ]
    }
}
