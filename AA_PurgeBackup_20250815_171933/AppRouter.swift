import SwiftUI
import Supabase

enum AppStage {
    case checking
    case unauth
    case setupNeeded(Session)
    case ready(UserContext)
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
            case .setupNeeded(let session):
                SetupFamilyView(session: session) { ctx in
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
            }
        }
        .task { await check() }
    }

    private func check() async {
        do {
            guard let session = try? await client.auth.session else {
                stage = .unauth; return
            }
            if let ctx = try? await SessionManager.resolveContext(using: client, session: session) {
                stage = .ready(ctx)
            } else {
                stage = .setupNeeded(session)
            }
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
