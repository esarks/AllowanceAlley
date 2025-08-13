import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: FamilyStore
    @State private var showAddChild = false

    var body: some View {
        NavigationStack {
            List {
                Section("\(store.familyName) Family") {
                    HStack {
                        Text("Children")
                        Spacer()
                        Text("\(store.children.count)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Total Points")
                        Spacer()
                        Text("\(store.totalPoints)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Kids") {
                    ForEach(store.children) { child in
                        NavigationLink(value: child) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(child.name).font(.headline)
                                    Text("Age \(child.age)").font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(child.points) pts")
                                    .font(.subheadline)
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Child.self) { child in
                ChildDetailView(child: child)
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddChild = true
                    } label: {
                        Label("Add Child", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddChild) {
                AddChildView()
                    .presentationDetents([.medium])
            }
        }
    }
}

struct ChildDetailView: View {
    @EnvironmentObject var store: FamilyStore
    let child: Child

    var body: some View {
        VStack(spacing: 20) {
            Text(child.name).font(.title2).bold()
            Text("Points: \(child.points)").font(.headline)

            HStack {
                Button("−10") { store.awardPoints(to: child.id, amount: -10) }
                Button("+10") { store.awardPoints(to: child.id, amount: 10) }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Child")
    }
}

struct AddChildView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: FamilyStore
    @State private var name = ""
    @State private var age = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Child name", text: $name)
                TextField("Age", text: $age)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Child")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addChild(name: name, age: Int(age) ?? 0)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
