import SwiftUI

public struct AAChoreEditorView: View {
    @EnvironmentObject private var familyStore: FamilyStore
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var dueDate: Date? = nil
    @State private var recurrence: AARecurrence = .none
    @State private var points: Int = 1
    @State private var assigneeIdx: Int = 0
    @State private var photoRequired = false
    public var onSave: (AAChore) -> Void

    public init(onSave: @escaping (AAChore) -> Void) { self.onSave = onSave }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $detail, axis: .vertical)
                }
                Section("Schedule") {
                    Toggle("Has due date", isOn: Binding(get: { dueDate != nil }, set: { $0 ? (dueDate = Date()) : (dueDate = nil) }))
                    if let _ = dueDate {
                        DatePicker("Due", selection: Binding(get: { dueDate ?? Date() }, set: { dueDate = $0 }), displayedComponents: .date)
                    }
                    Picker("Recurrence", selection: $recurrence) {
                        ForEach(AARecurrence.allCases, id: \.self) { Text($0.rawValue.capitalized) }
                    }
                }
                Section("Assignment & Value") {
                    Stepper("Points: \(points)", value: $points, in: 1...50)
                    Picker("Assign to", selection: $assigneeIdx) {
                        ForEach(Array(familyStore.children.enumerated()), id: \.offset) { idx, child in
                            Text(child.name).tag(idx)
                        }
                    }
                    Toggle("Require photo proof", isOn: $photoRequired)
                }
            }
            .navigationTitle("New Chore")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !familyStore.children.isEmpty else { return }
                        let assigneeId = familyStore.children[assigneeIdx].id
                        let chore = AAChore(title: title, detail: detail, dueDate: dueDate, recurrence: recurrence, points: points, assigneeId: assigneeId, photoRequired: photoRequired)
                        onSave(chore)
                    }.disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
