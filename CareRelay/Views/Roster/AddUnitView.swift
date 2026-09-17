import SwiftUI
import SwiftData

struct AddUnitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Unit name", text: $name)
                } footer: {
                    Text("This is the name staff will see when assigning an entry or resident to a unit.")
                }
            }
            .navigationTitle("New Unit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        let unit = Unit(name: name)
        modelContext.insert(unit)
        dismiss()
    }
}
