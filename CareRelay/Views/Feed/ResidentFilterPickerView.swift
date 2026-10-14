import SwiftUI
import SwiftData

struct ResidentFilterPickerView: View {
    @Binding var selectedResident: Resident?
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Resident.name) private var residents: [Resident]
    @State private var searchText = ""

    private var filteredResidents: [Resident] {
        guard !searchText.isEmpty else { return residents }
        return residents.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredResidents) { resident in
                    Button {
                        selectedResident = resident
                        dismiss()
                    } label: {
                        HStack {
                            Text(resident.name)
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedResident?.id == resident.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(AppColor.accent)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search residents")
            .navigationTitle("Filter by Resident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if selectedResident != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Clear") {
                            selectedResident = nil
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
