import SwiftUI
import SwiftData

struct AddStaffView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var role: StaffRole = .caregiver

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                }

                Section {
                    Picker("Role", selection: $role) {
                        ForEach(StaffRole.allCases, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                } footer: {
                    Text("Nurse in Charge and Supervisor can resolve open Alerts. Caregiver cannot.")
                }
            }
            .navigationTitle("New Staff")
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
        let staff = Staff(name: name, role: role)
        modelContext.insert(staff)
        dismiss()
    }
}
