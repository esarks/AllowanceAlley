import SwiftUI
import Supabase

enum AppStage {
    case checking
    case unauth
    case needsSetup
    case ready(UserContext)
    case error(String)
}

public struct AppRouterView: View {
    @State private var stage: AppStage = .checking
    private let client: SupabaseClient = SupabaseManager.shared.client

    public init() {}

    public var body: some View {
        Group {
            switch stage {
            case .checking:
                ProgressView("Loading…")
            case .unauth:
                LoginPlaceholderView() // Use your existing login view here if different
            case .needsSetup:
                SetupFamilyView { ctx in stage = .ready(ctx) }
            case .ready(let ctx):
                RootTabs(familyId: ctx.familyId, role: ctx.role, childUserId: ctx.childUserId)
            case .error(let message):
                VStack(spacing: 12) {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
                    Button("Retry") { Task { await check() } }
                }.padding()
            }
        }
        .task { await check() }
    }

    private func check() async {
        // Safely get a session; treat nil or failure as signed-out
        guard let _ = try? await client.auth.session else {
            stage = .unauth
            return
        }
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
