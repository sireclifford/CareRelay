import SwiftUI
import SwiftData

struct AddResidentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Unit.name) private var units: [Unit]

    @State private var name: String = ""
    @State private var selectedUnit: Unit?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Picker("Unit", selection: $selectedUnit) {
                    Text("Select unit").tag(Unit?.none)
                    ForEach(units) { unit in
                        Text(unit.name).tag(Unit?.some(unit))
                    }
                }
            }
            .navigationTitle("New Resident")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty || selectedUnit == nil)
                }
            }
        }
    }

    private func save() {
        let resident = Resident(name: name, unit: selectedUnit)
        modelContext.insert(resident)
        dismiss()
    }
}
