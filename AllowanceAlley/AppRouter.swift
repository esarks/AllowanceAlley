import SwiftUI
import Supabase

enum AppStage {
    case checking
    case unauth
    case ready(UserContext)
    case error(String)
}

public struct AppRouterView: View {
    @State private var stage: AppStage = .checking

    // Point this to your shared client if named differently
    let client: SupabaseClient = SupabaseManager.shared.client

    public init() {}

    public var body: some View {
        Group {
            switch stage {
            case .checking:
                ProgressView("Signing in…")
            case .unauth:
                LoginPlaceholderView()
            case .ready(let ctx):
                RootTabs(familyId: ctx.familyId, role: ctx.role, childUserId: ctx.childUserId)
            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                    Button("Retry") { Task { await check() } }
                }
            }
        }
        .task { await check() }    // run once on appear
        // NOTE: removed auth listener to avoid SDK signature mismatches for now
    }

    private func check() async {
        // Safely fetch session; treat failure or nil as signed-out
        let hasSession = (try? await client.auth.session) != nil
        guard hasSession else {
            stage = .unauth
            return
        }

        do {
            let ctx = try await RoleResolver.resolve(using: client)
            stage = .ready(ctx)
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
