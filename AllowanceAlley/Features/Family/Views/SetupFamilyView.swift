import SwiftUI

struct SetupFamilyView: View {
  let onFinished: () -> Void

  init(onFinished: @escaping () -> Void) {
    self.onFinished = onFinished
  }

  var body: some View {
    VStack(spacing: 12) {
      Text("Family setup").font(.title2)
      Button("Finish Setup") { onFinished() }
    }
    .padding()
  }
}
