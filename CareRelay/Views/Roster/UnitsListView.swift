import SwiftUI
import SwiftData

struct UnitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Unit.name) private var units: [Unit]
    @State private var isPresentingAdd = false

    var body: some View {
        Group {
            if units.isEmpty {
                ContentUnavailableView(
                    "No Units Yet",
                    systemImage: "building.2",
                    description: Text("Tap the + button to add your first unit.")
                )
            } else {
                List {
                    ForEach(units) { unit in
                        UnitRow(unit: unit)
                    }
                    .onDelete(perform: deleteUnits)
                }
            }
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

private struct UnitRow: View {
    let unit: Unit

    private var residentCount: Int {
        unit.residents?.count ?? 0
    }

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.accent.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }

            Text(unit.name)

            Spacer()

            Text("\(residentCount) resident\(residentCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
