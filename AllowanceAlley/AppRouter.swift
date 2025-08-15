import SwiftUI
import Supabase

// Rename to avoid "Invalid redeclaration of AppStage"
enum RouterStage {
    case checking
    case unauth
    case ready(UserContext)
    case needsSetup
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
                // Your existing login screen
                LoginPlaceholderView()

            case .needsSetup:
                SetupFamilyView { ctx in
                    stage = .ready(ctx)
                }

            case .ready(let ctx):
                RootTabs(
                    familyId: ctx.familyId,
                    role: ctx.role,
                    childUserId: ctx.childUserId
                )

            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    Button("Retry") { Task { await check() } }
                }
                .padding()
            }
        }
        .task { await check() }
    }

    private func check() async {
        // 1) Confirm we have a session
        let hasSession = (try? await client.auth.session) != nil
        guard hasSession else {
            stage = .unauth
            return
        }

        // 2) Resolve role + family
        do {
            let ctx = try await RoleResolver.resolve(using: client)
            stage = .ready(ctx)
        } catch let e as NSError where e.code == 404 {
            // Signed-in but no family linkage yet
            stage = .needsSetup
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
