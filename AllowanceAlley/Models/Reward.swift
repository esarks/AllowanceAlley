import Foundation

struct Reward: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var title: String
    var details: String
    var costPoints: Int
    var imageURL: URL? = nil
    var active: Bool = true
}
