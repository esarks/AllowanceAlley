
import SwiftUI

/// Optional adapter that uses your FamilyStore to supply a childId.
struct ChoresTabView: View {
    var body: some View {
        ChoresV2View() // will pick first child automatically via FamilyStore
    }
}
