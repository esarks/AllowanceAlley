import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var familyStore = FamilyStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyStore)
        }
    }
}
