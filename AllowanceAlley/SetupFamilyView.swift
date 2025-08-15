// SetupFamilyView.swift
import SwiftUI

struct SetupFamilyView: View {
    var onFinished: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Family setup").font(.title2)
            Button("Finish Setup") { onFinished() }
        }
        .padding()
    }
}
