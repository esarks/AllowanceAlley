import SwiftUI
import Supabase

// Use a new name to avoid collisions with any old AppStage symbols
enum RouterStage {
    case checking
    case unauth
    case ready(UserContext)    // has family + role
    case needsSetup            // signed in but not linked to a family
    case error(String)
}

public struct AppRouterView: View {
    @State private var stage: RouterStage = .checking
    private let client: SupabaseClient = SupabaseService.shared.client

    public init() {}

    public var body: some View {
        Group {
            switch stage {
            case .checking:
                ProgressView("Loading…")

            case .unauth:
                // Your existing sign-in screen view
                LoginPlaceholderView()

            case .needsSetup:
                SetupFamilyView { ctx in
                    stage = .ready(ctx)
                }

            case .ready(let ctx):
                RootTabs(familyId: ctx.familyId, role: ctx.role, childUserId: ctx.childUserId)

            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView("Error",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(message))
                    Button("Retry") { Task { await check() } }
                }
                .padding()
            }
        }
        .task { await check() }
    }

    private func check() async {
        // 1) Confirm session
        let hasSession = (try? await client.auth.session) != nil
        guard hasSession else { stage = .unauth; return }

        // 2) Resolve role + family
        do {
            let ctx = try await RoleResolver.resolve(using: client)
            stage = .ready(ctx)
        } catch let e as NSError where e.code == 404 {
            stage = .needsSetup
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
