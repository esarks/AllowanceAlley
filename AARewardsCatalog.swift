import Foundation

public struct AAReward: Identifiable, Hashable {
    public var id = UUID()
    public var name: String
    public var cost: Int
}

public enum AARewardsCatalog {
    public static var demo: [AAReward] = [
        .init(name: "Extra screen time", cost: 5),
        .init(name: "Pick dessert",     cost: 3),
        .init(name: "Stay up late",     cost: 7),
        .init(name: "Choose movie",     cost: 6)
    ]
}
