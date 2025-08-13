import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var store: FamilyStore
    @State private var parentName = "Parent"

    var body: some View {
        NavigationStack {
            Form {
                Section("Parent") {
                    TextField("Name", text: $parentName)
                }
                Section("Family") {
                    TextField("Family Name", text: $store.familyName)
                }
            }
            .navigationTitle("Profile")
        }
    }
}
