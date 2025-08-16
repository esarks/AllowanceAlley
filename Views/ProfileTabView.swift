import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var store: FamilyStore

    var body: some View {
        List {
            Section("Family") {
                Text(store.familyName)
                Text("Children: \(store.children.count)")
                Text("Total Points: \(store.totalPoints)")
            }
            if !store.parents.isEmpty {
                Section("Parents") {
                    ForEach(store.parents) { parent in
                        Text(parent.name)
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
}
