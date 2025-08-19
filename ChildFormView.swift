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
    @State private var avatarData: Data?

    init(mode: Mode,
         onSave: @escaping (_ name: String, _ birthdate: Date?, _ avatarData: Data?) -> Void)
    {
        self.mode = mode
        self.onSave = onSave
        switch mode {
        case .create:
            break
        case .edit(let c):
            _name = State(initialValue: c.name)
            _birthdate = State(initialValue: c.birthdate)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basics") {
                    TextField("Name", text: $name)
                    DatePicker(
                        "Birthdate",
                        selection: Binding(unwrapping: $birthdate, default: Date()),
                        displayedComponents: .date
                    )
                }

                Section("Avatar") {
                    HStack(spacing: 16) {
                        avatarPreview
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                        PhotosPicker(
                            selection: $pickerItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Choose Photo")
                            }
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
            .onChange(of: pickerItem) { newItem in
                Task { await loadJPEG(from: newItem) }
            }
        }
    }

    // MARK: UI bits

    private var modeTitle: String {
        switch mode { case .create: "Add Child"; case .edit: "Edit Child" }
    }

    @ViewBuilder private var avatarPreview: some View {
        if let data = avatarData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            Color.secondary.opacity(0.15)
        }
    }

    // MARK: Image loader

    private func loadJPEG(from item: PhotosPickerItem?) async {
        guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
        // Normalize to jpeg to keep contentType stable
        if let img = UIImage(data: data),
           let jpeg = img.jpegData(compressionQuality: 0.9) {
            self.avatarData = jpeg
        } else {
            self.avatarData = data // fallback
        }
    }
}

// Small Binding helper to allow optional Date selection
private extension Binding where Value == Date? {
    init(unwrapping source: Binding<Date?>, default defaultValue: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}
