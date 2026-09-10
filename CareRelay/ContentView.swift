import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var units: [Unit]

    var body: some View {
            NavigationStack {
                List {
                    ForEach(units) { unit in
                        Text(unit.name)
                    }
                    .onDelete(perform: deleteUnits)
                }
                .navigationTitle("Units")
                .toolbar {
                    ToolbarItem {
                        Button(action: addSampleUnit) {
                            Label("Add Unit", systemImage: "plus")
                        }
                    }
                }
            }
        }


    private func addSampleUnit() {
            let unit = Unit(name: "Unit \(units.count + 1)")
            modelContext.insert(unit)
        }

        private func deleteUnits(offsets: IndexSet) {
            for index in offsets {
                modelContext.delete(units[index])
            }
        }
}

#Preview {
    ContentView()
        .modelContainer(for: Unit.self, inMemory: true)
}
