
import SwiftUI

/// Optional adapter that uses your FamilyStore to supply a childId.
struct RewardsTabView: View {
    var body: some View {
        RewardsV2View() // will pick first child automatically via FamilyStore
    }
}
