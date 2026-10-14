import SwiftUI
import SwiftData

struct ResidentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    @Query(sort: \Resident.name) private var residents: [Resident]
    @Query(sort: \Unit.name) private var units: [Unit]
    @State private var isPresentingAdd = false

    private var canManage: Bool {
        session.currentStaff?.role.canManageRoster ?? false
    }

    private var emptyStateDescription: String {
        canManage ? "Tap the + button to add your first resident." : "Residents will appear here once added."
    }

    private var residentSections: [(title: String, residents: [Resident])] {
        var sections: [(title: String, residents: [Resident])] = units.compactMap { unit in
            let group = residents.filter { $0.unit?.id == unit.id }
            return group.isEmpty ? nil : (unit.name, group)
        }
        let unassigned = residents.filter { $0.unit == nil }
        if !unassigned.isEmpty {
            sections.append(("No Unit", unassigned))
        }
        return sections
    }

    var body: some View {
        Group {
            if residents.isEmpty {
                ContentUnavailableView(
                    "No Residents Yet",
                    systemImage: "bed.double",
                    description: Text(emptyStateDescription)
                )
            } else if canManage {
                List {
                    ForEach(residentSections, id: \.title) { section in
                        Section(section.title) {
                            ForEach(section.residents) { resident in
                                ResidentRow(resident: resident)
                            }
                            .onDelete { offsets in
                                deleteResidents(section.residents, at: offsets)
                            }
                        }
                    }
                }
            } else {
                List {
                    ForEach(residentSections, id: \.title) { section in
                        Section(section.title) {
                            ForEach(section.residents) { resident in
                                ResidentRow(resident: resident)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Residents")
        .toolbar {
            if canManage {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddResidentView()
        }
    }

    private func deleteResidents(_ source: [Resident], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(source[index])
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
