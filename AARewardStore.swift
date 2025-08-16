import Foundation

public struct AAReward: Identifiable, Codable, Equatable {
    public var id = UUID()
    public var name: String
    public var cost: Int
}
public enum AARequestStatus: String, Codable { case requested, approved, rejected }

public struct AARedemptionRequest: Identifiable, Codable, Equatable {
    public var id = UUID()
    public var childId: UUID
    public var reward: AAReward
    public var status: AARequestStatus = .requested
    public var at: Date = .init()
}

@MainActor
public final class AARewardStore: ObservableObject {
    @Published public private(set) var rewards: [AAReward] = [
        .init(name: "Extra screen time", cost: 5),
        .init(name: "Pick dessert", cost: 3),
        .init(name: "Stay up late", cost: 7)
    ]
    @Published public private(set) var requests: [AARedemptionRequest] = []

    public init() { load() }

    public func addReward(_ r: AAReward) { rewards.append(r); save() }
    public func deleteRewards(at offsets: IndexSet) { rewards.remove(atOffsets: offsets); save() }

    public func request(_ reward: AAReward, for childId: UUID) { requests.append(.init(childId: childId, reward: reward)); save() }
    public func approve(_ req: AARedemptionRequest) {
        if let i = requests.firstIndex(where: { $0.id == req.id }) { requests[i].status = .approved; save() }
    }
    public func reject(_ req: AARedemptionRequest) {
        if let i = requests.firstIndex(where: { $0.id == req.id }) { requests[i].status = .rejected; save() }
    }

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("aa_rewards.json")
    }
    private func save() {
        do {
            let payload = try JSONEncoder().encode(RequestsWrapper(rewards: rewards, requests: requests))
            try payload.write(to: fileURL, options: .atomic)
        } catch { print("AARewardStore save error:", error) }
    }
    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(RequestsWrapper.self, from: data)
            rewards = decoded.rewards; requests = decoded.requests
        } catch { /* keep defaults */ }
    }

    private struct RequestsWrapper: Codable {
        var rewards: [AAReward]
        var requests: [AARedemptionRequest]
    }
}
