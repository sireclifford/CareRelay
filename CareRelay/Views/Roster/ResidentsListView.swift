import SwiftUI
import SwiftData

struct ResidentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Resident.name) private var residents: [Resident]
    @State private var isPresentingAdd = false

    var body: some View {
        Group {
            if residents.isEmpty {
                ContentUnavailableView(
                    "No Residents Yet",
                    systemImage: "bed.double",
                    description: Text("Tap the + button to add your first resident.")
                )
            } else {
                List {
                    ForEach(residents) { resident in
                        ResidentRow(resident: resident)
                    }
                    .onDelete(perform: deleteResidents)
                }
            }
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

private struct ResidentRow: View {
    let resident: Resident

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColor.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(resident.name)
                Text(resident.unit?.name ?? "No unit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
