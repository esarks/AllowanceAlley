import SwiftUI
import PhotosUI

struct ChildFormView: View {
    enum Mode { case create, edit(existing: Child) }

    let mode: Mode
    /// Called when the user taps Save.
    /// Passes: name, optional birthdate, optional avatar image data (JPEG/PNG)
    var onSave: (_ name: String, _ birthdate: Date?, _ avatarData: Data?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var birthdate: Date? = nil
    @State private var pickerItem: PhotosPickerItem?
    @State private var avatarData: Data?

    // MARK: - Init seeds state for edit mode
    init(
        mode: Mode,
        onSave: @escaping (_ name: String, _ birthdate: Date?, _ avatarData: Data?) -> Void
    ) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _name = State(initialValue: "")
            _birthdate = State(initialValue: nil)
        case .edit(let existing):
            _name = State(initialValue: existing.name)
            _birthdate = State(initialValue: existing.birthdate)
        }
    }

    // Convert our optional Date state into a non-optional Binding for DatePicker
    private var birthdateBinding: Binding<Date> {
        Binding<Date>(
            get: { birthdate ?? Date() },
            set: { birthdate = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    DatePicker("Birthdate",
                               selection: birthdateBinding,
                               displayedComponents: .date)
                }

                Section("Avatar") {
                    avatarPreview
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())

                    PhotosPicker(selection: $pickerItem,
                                 matching: .images,
                                 photoLibrary: .shared()) {
                        Text("Choose Photo")
                    }
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(name, birthdate, avatarData)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            // iOS 17+ preferred signature
            .onChange(of: pickerItem) { _, newItem in
                Task { await loadImageData(from: newItem) }
            }
        }
    }

    // MARK: - Helpers

    private var modeTitle: String {
        switch mode {
        case .create: return "Add Child"
        case .edit:   return "Edit Child"
        }
    }

    @ViewBuilder
    private var avatarPreview: some View {
        if let data = avatarData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            Color.secondary.opacity(0.15)
        }
    }

    private func loadImageData(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.avatarData = data
            }
        } catch {
            // keep silent; preview just stays placeholder
            print("PhotosPicker load error:", error.localizedDescription)
        }
    }
}
