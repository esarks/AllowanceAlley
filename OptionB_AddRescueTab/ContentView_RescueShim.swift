import SwiftUI

// Drop-in ContentView that **always** shows RescueRootView as an extra tab.
struct ContentView: View {
    var body: some View {
        TabView {
            Text("Existing Home")
                .tabItem { Label("Home", systemImage: "house") }
            RescueRootView()
                .tabItem { Label("Rescue", systemImage: "lifepreserver") }
        }
    }
}
