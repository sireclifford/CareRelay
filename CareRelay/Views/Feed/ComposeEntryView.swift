import SwiftUI
import SwiftData

struct ComposeEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Session.self) private var session

    @Query private var units: [Unit]
    @Query private var residents: [Resident]

    @State private var kind: EntryKind = .notice
    @State private var selectedUnit: Unit?
    @State private var selectedResident: Resident?
    @State private var category: EntryCategory = .other
    @State private var content: String = ""

    var body: some View {
            NavigationStack {
                Form {
                    Section("Type") {
                        Picker("Kind", selection: $kind) {
                            Text("Notice").tag(EntryKind.notice)
                            Text("Alert").tag(EntryKind.alert)
                        }
                        .pickerStyle(.segmented)

                        Picker("Category", selection: $category) {
                            ForEach(EntryCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                    }

                    Section("Where") {
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
                    }

                    Section("Details") {
                        TextField("What's going on?", text: $content, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
                .navigationTitle("New Entry")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { save() }
                            .disabled(content.isEmpty || session.currentStaff == nil)
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
               content: content,
               author: session.currentStaff
           )
           modelContext.insert(entry)
           dismiss()
       }
}
