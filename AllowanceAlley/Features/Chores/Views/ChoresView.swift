// ChoresView.swift
import SwiftUI

struct ChoresView: View {
  let familyId: UUID
  let childId: UUID?

  init(familyId: UUID? = nil, childId: UUID? = nil) {
    self.familyId = familyId ?? UUID() // placeholder; swap for real id later
    self.childId  = childId
  }

  var body: some View { Text("Chores") }
}
