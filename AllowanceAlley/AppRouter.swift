import SwiftUI
import Supabase

enum AppStage {
    case checking
    case unauth
    case ready(UserContext)    // has family + role
    case needsSetup            // signed in, but no family/member yet
    case error(String)
}

public struct AppRouterView: View {
    @State private var stage: AppStage = .checking
    let client: SupabaseClient = SupabaseManager.shared.client

    public init() {}

    public var body: some View {
        Group {
            switch stage {
            case .checking:
                ProgressView("Loading…")
            case .unauth:
                LoginPlaceholderView()
            case .needsSetup:
                SetupFamilyView(onFinished: { ctx in stage = .ready(ctx) })
            case .ready(let ctx):
                RootTabs(familyId: ctx.familyId, role: ctx.role, childUserId: ctx.childUserId)
            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView("Error",
                                           systemImage: "exclamationmark.triangle",
                                           description: Text(message))
                    Button("Retry") { Task { await check() } }
                }
            }
        }
        .task { await check() }
    }

    private func check() async {
        // Signed in?
        guard (try? await client.auth.session) != nil else {
            stage = .unauth
            return
        }
        // Resolve context (family + role) or show setup
        do {
            let ctx = try await RoleResolver.resolve(using: client)
            stage = .ready(ctx)
        } catch let err as NSError where err.code == 404 {
            stage = .needsSetup
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
