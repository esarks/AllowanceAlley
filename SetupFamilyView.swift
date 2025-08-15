import SwiftUI

public struct SetupFamilyView: View {
    var onFinished: () -> Void
    public init(onFinished: @escaping () -> Void) { self.onFinished = onFinished }
    public var body: some View {
        VStack(spacing: 12) {
            Text("Family setup").font(.title2)
            Button("Finish Setup") { onFinished() }
        }.padding()
    }
}
