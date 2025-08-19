import SwiftUI
import PhotosUI

struct ChildFormView: View {
    enum Mode { case create, edit(existing: Child) }

    let mode: Mode
    var onSave: (_ name: String, _ birthdate: Date?, _ avatarData: Data?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var birthdate: Date?
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    init(mode: Mode,
         onSave: @escaping (_ name: String, _ birthdate: Date?, _ avatarData: Data?) -> Void) {
        self.mode = mode
        self.onSave = onSave
        switch mode {
        case .create: break
        case .edit(let c):
            _name = State(initialValue: c.name)
            _birthdate = State(initialValue: c.birthdate)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Child's name", text: $name)

                    DatePicker(
                        "Birthdate",
                        selection: Binding<Date>(unwrapping: $birthdate, default: Date()),
                        displayedComponents: .date
                    )
                }

                Section("Avatar") {
                    HStack {
                        avatarPreview
                        Spacer()
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Text("Choose Photo")
                        }
                    }
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name.trimmingCharacters(in: .whitespacesAndNewlines), birthdate, imageData)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onChange(of: pickerItem) { _ in
                Task {
                    if let data = try? await pickerItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }

    private var modeTitle: String {
        switch mode { case .create: "Add Child"; case .edit: "Edit Child" }
    }

    private var avatarPreview: some View {
        Group {
            if let data = imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable().scaledToFill()
            } else {
                Image(systemName: "person.fill").resizable().scaledToFit()
                    .padding(16).foregroundStyle(.secondary)
                    .background(Color.secondary.opacity(0.15))
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
    }
}

// Helper: make a Binding<Date> from a Binding<Date?>
private extension Binding where Value == Date {
    init(unwrapping source: Binding<Date?>, default defaultValue: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}
