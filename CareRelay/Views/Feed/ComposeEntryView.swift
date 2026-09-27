import SwiftUI
import SwiftData

struct ComposeEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Session.self) private var session

    @Query(sort: \Unit.name) private var units: [Unit]
    @Query(sort: \Resident.name) private var residents: [Resident]

    @State private var kind: EntryKind = .notice
    @State private var selectedUnit: Unit?
    @State private var selectedResident: Resident?
    @State private var category: EntryCategory = .other
    @State private var content: String = ""

    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kind", selection: $kind) {
                        Text("Notice").tag(EntryKind.notice)
                        Text("Alert").tag(EntryKind.alert)
                    }
                    .pickerStyle(.segmented)

                    Picker("Category", selection: $category) {
                        ForEach(EntryCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                } header: {
                    Text("Type")
                } footer: {
                    Text(kind == .alert
                         ? "Alerts are pinned at the top of the feed and stay open until resolved."
                         : "Notices are informational and don't need to be resolved.")
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
                } footer: {
                    Text("Leave Unit as Facility-wide for entries that affect everyone. Resident is optional.")
                }

                Section {
                    TextField("What's going on?", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Details")
                } footer: {
                    Text("Posted as \(session.currentStaff?.name ?? "the signed-in staff member").")
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedContent.isEmpty || session.currentStaff == nil)
                }
            }
        }
    }

    private func save() {
        let entry = Entry(
            kind: kind,
            unit: selectedUnit,
            resident: selectedResident,
            category: category,
            content: trimmedContent,
            author: session.currentStaff
        )
        modelContext.insert(entry)
        dismiss()
    }
}
