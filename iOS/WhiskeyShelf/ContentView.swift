import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingItem: BottleItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.items.isEmpty {
                    VStack(spacing: 12) {
                        Text("No bottles yet")
                            .font(Theme.headlineFont)
                            .foregroundColor(Theme.textPrimary)
                        Text("Tap + to log your first one.")
                            .font(Theme.captionFont)
                            .foregroundColor(Theme.textMuted)
                    }
                } else {
                    List {
                        ForEach(store.items) { entry in
                            Button {
                                editingItem = entry
                            } label: {
                                row(for: entry)
                            }
                            .listRowBackground(Theme.surface)
                            .accessibilityIdentifier("itemRow_\(entry.name)")
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Theme.background)
                }
            }
            .navigationTitle("Whiskey Shelf")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd() {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                ItemEditView(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editingItem) { entry in
                ItemEditView(mode: .edit(entry))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }

    @ViewBuilder
    private func row(for entry: BottleItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Distillery: \(entry.distillery)  \u{2022}  Fill Level: \(entry.fillLevel)")
                .font(Theme.captionFont)
                .foregroundColor(Theme.textMuted)
        }
        .padding(.vertical, 4)
    }
}

enum ItemEditMode: Equatable {
    case add
    case edit(BottleItem)

    static func == (lhs: ItemEditMode, rhs: ItemEditMode) -> Bool {
        switch (lhs, rhs) {
        case (.add, .add): return true
        case (.edit(let a), .edit(let b)): return a.id == b.id
        default: return false
        }
    }
}

struct ItemEditView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: ItemEditMode

    @State private var name: String = ""
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var notes: String = ""
    @FocusState private var focusedField: Field?

    enum Field { case name, field1, field2, notes }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                        .accessibilityIdentifier("nameField")
                    TextField("Distillery (Glenfiddich)", text: $field1)
                        .focused($focusedField, equals: .field1)
                        .accessibilityIdentifier("field1Field")
                    TextField("Fill Level (80%)", text: $field2)
                        .focused($focusedField, equals: .field2)
                        .accessibilityIdentifier("field2Field")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("notesField")
                }
                if case .edit(let entry) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(entry)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(mode == .add ? "Add Bottle" : "Edit Bottle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .accessibilityIdentifier("saveButton")
                }
            }
        }
        .onAppear {
            if case .edit(let entry) = mode {
                name = entry.name
                field1 = entry.distillery
                field2 = entry.fillLevel
                notes = entry.notes
            }
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(name: name, distillery: field1, fillLevel: field2, notes: notes)
        case .edit(var entry):
            entry.name = name
            entry.distillery = field1
            entry.fillLevel = field2
            entry.notes = notes
            store.update(entry)
        }
        dismiss()
    }
}
