import SwiftUI
import SwiftData

struct EditEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Session.self) private var session
    
    @Query(sort: \Unit.name) private var units: [Unit]
    @Query(sort: \Resident.name) private var residents: [Resident]
    
    let entry: Entry
    
    @State private var selectedUnit: Unit?
    @State private var selectedResident: Resident?
    @State private var category: EntryCategory
    @State private var content: String
    
    init(entry: Entry) {
        self.entry = entry
        _selectedUnit = State(initialValue: entry.unit)
        _selectedResident = State(initialValue: entry.resident)
        _category = State(initialValue: entry.category)
        _content = State(initialValue: entry.content)
    }
    
    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(EntryCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                } footer: {
                    Text("The kind, Notice or Alert, can't be changed once an entry is created.")
                }
                
                Section {
                    Picker("Unit", selection: $selectedUnit) {
                        Text("Facility-wide").tag(Unit?.none)
                        ForEach(units) { unit in
                            Text(unit.name).tag(Unit?.some(unit))
                        }
                    }
                    
                    Picker("Resident", selection: $selectedResident) {
                        Text("None").tag(Resident?.none)
                        ForEach(residents) { resident in
                            Text(resident.name).tag(Resident?.some(resident))
                        }
                    }
                } header: {
                    Text("Where")
                }
                
                Section {
                    TextField("What's going on?", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Details")
                }
            }
            .navigationTitle("Edit Entry")
            .dismissableKeyboard()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedContent.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        AuditEvent.log(
            .entryEdited,
            actor: session.currentStaff,
            target: "Entry by \(entry.displayAuthorName) (\(entry.createdAt.formatted(date: .abbreviated, time: .shortened)))",
            in: modelContext
        )
        entry.category = category
        entry.unit = selectedUnit
        entry.resident = selectedResident
        entry.content = trimmedContent
        dismiss()
    }
}
