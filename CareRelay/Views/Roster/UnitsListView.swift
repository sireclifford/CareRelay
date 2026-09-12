import SwiftUI
import SwiftData

struct UnitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Unit.name) private var units: [Unit]
    @State private var isPresentingAdd = false

    var body: some View {
        List {
            ForEach(units) { unit in
                Text(unit.name)
            }
            .onDelete(perform: deleteUnits)
        }
        .navigationTitle("Units")
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
            AddUnitView()
        }
    }

    private func deleteUnits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(units[index])
        }
    }
}
