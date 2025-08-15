import SwiftUI

struct DashboardView: View {
    let familyId: UUID
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    Label("Family ID: \(familyId.uuidString.prefix(8))…", systemImage: "person.3")
                    Label("Pending approvals", systemImage: "inbox")
                    Label("Today’s chores", systemImage: "calendar")
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}
