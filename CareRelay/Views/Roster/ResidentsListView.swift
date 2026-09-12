import SwiftUI
import SwiftData

struct ResidentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Resident.name) private var residents: [Resident]
    @State private var isPresentingAdd = false

    var body: some View {
        List {
            ForEach(residents) { resident in
                VStack(alignment: .leading) {
                    Text(resident.name)
                    Text(resident.unit?.name ?? "No unit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: deleteResidents)
        }
        .navigationTitle("Residents")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddResidentView()
        }
    }

    private func deleteResidents(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(residents[index])
        }
    }
}
