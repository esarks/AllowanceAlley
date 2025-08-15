import SwiftUI

@main
struct AllowanceAlleyApp: App {
    @StateObject private var familyStore = FamilyStore()        // or FamilyStore.demo()
    @StateObject private var supabase    = SupabaseService()     // if you use this

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyStore)                  // ⬅️ required
                .environmentObject(supabase)                     // if used elsewhere
        }
    }
}
