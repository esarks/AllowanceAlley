import SwiftUI
import Supabase

public struct LoginPlaceholderView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 16) {
            ContentUnavailableView("Not Signed In", systemImage: "person.crop.circle.badge.exclamationmark",
                                   description: Text("Sign in to continue."))
        }
        .padding()
    }
}
