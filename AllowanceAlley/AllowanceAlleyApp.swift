import SwiftUI
import Supabase

@main
struct AllowanceAlleyApp: App {
    private let client = SupabaseManager.shared.client

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    print("🔗 onOpenURL received: \(url.absoluteString)")
                    Task {
                        do {
                            try await client.auth.session(from: url)
                            print("✅ Supabase session restored from redirect")
                        } catch {
                            print("❌ Failed to restore session from redirect:", error.localizedDescription)
                        }
                    }
                }
        }
    }
}
