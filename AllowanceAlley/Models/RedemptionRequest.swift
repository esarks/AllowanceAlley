import Foundation

enum RedemptionStatus: String, Codable, CaseIterable {
    case pending, approved, rejected
}

struct RedemptionRequest: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var reward: Reward
    var childId: UUID
    var note: String? = nil
    var status: RedemptionStatus = .pending
    var createdAt: Date = .init()
    var decidedAt: Date? = nil
}
