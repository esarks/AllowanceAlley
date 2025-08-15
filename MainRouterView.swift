import SwiftUI

public struct MainRouterView: View {
    @EnvironmentObject var client: SupabaseService
    @State private var stage: AppTypes.Stage = .unauth
    @State private var message: String = "Checking…"

    public init() {}

    public var body: some View {
        content
            .task { await check() }
    }

    @ViewBuilder private var content: some View {
        switch stage {
        case .unauth:
            VStack(spacing: 12) {
                Label("Sign in required", systemImage: "exclamationmark.triangle")
                Text(message).font(.footnote)
                Button("Retry") { Task { await check() } }
            }
            .padding()

        case .needsSetup:
            SetupFamilyView(onFinished: {
                // Re-run checks after the user finishes setup
                Task { await check() }
            })

        case .ready(let ctx):
            RootTabsView(context: ctx)

        case .error(let err):
            VStack(spacing: 12) {
                Label("Something went wrong", systemImage: "exclamationmark.triangle")
                Text(err).font(.footnote).multilineTextAlignment(.center)
                Button("Retry") { Task { await check() } }
            }
            .padding()
        }
    }

    private func check() async {
        // 1) Confirm we have a session
        let hasSession = (try? await client.session()) != nil
        guard hasSession else { stage = .unauth; return }

        // 2) Resolve role + family or go to setup
        do {
            let ctx = try await RoleResolver.resolve(using: client)
            stage = .ready(ctx)
        } catch RoleResolverError.needsSetup {
            stage = .needsSetup
        } catch {
            stage = .error(error.localizedDescription)
        }
    }
}
