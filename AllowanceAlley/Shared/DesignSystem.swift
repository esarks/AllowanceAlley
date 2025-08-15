import SwiftUI

enum DS {
    static let cornerRadius: CGFloat = 16
    static let spacing: CGFloat = 12
    static let padding: CGFloat = 16

    static func card() -> some View {
        RoundedRectangle(cornerRadius: DS.cornerRadius)
            .fill(Color(.secondarySystemBackground))
            .shadow(radius: 1)
    }
}
