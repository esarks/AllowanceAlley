// RewardsView.swift
import SwiftUI

struct RewardsView: View {
  let familyId: UUID
  let childId: UUID?

  init(familyId: UUID? = nil, childId: UUID? = nil) {
    self.familyId = familyId ?? UUID()
    self.childId  = childId
  }

  var body: some View { Text("Rewards") }
}
