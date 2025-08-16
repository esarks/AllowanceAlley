import SwiftUI

@main
struct AllowanceAlleyApp: App {
    init() {
        print("🚨 RESCUE MODE ACTIVE — Option A @main replacement is running")
    }
    var body: some Scene {
        WindowGroup {
            RescueRootView()
                .tint(.orange)
                .overlay(alignment: .top) {
                    Text("RESCUE MODE")
                        .font(.caption2).bold()
                        .padding(6)
                        .background(.orange.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 6)
                }
        }
    }
}
