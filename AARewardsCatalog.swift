
import Foundation

struct AAReward: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var cost: Int
}

enum AARewardsCatalog {
    static var demo: [AAReward] = [
        .init(name: "Extra screen time", cost: 5),
        .init(name: "Pick dessert",     cost: 3),
        .init(name: "Stay up late",     cost: 7),
        .init(name: "Choose movie",     cost: 6)
    ]
}
