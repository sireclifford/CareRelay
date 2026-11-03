import SwiftUI
import SwiftData

struct ResidentsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    @Query(sort: \Resident.name) private var residents: [Resident]
    @Query(sort: \Unit.name) private var units: [Unit]
    @State private var isPresentingAdd = false
    @State private var pendingDeleteResident: Resident?
    @State private var blockedDeleteMessage: String?

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
                                    .swipeActions(edge: .trailing) {
                                        Button {
                                            requestDelete(resident)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
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
        .confirmationDialog(
            "Delete this resident?",
            isPresented: Binding(
                get: { pendingDeleteResident != nil },
                set: { if !$0 { pendingDeleteResident = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDeleteResident
        ) { resident in
            Button("Delete \(resident.name)", role: .destructive) {
                performDelete(resident)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This can't be undone.")
        }
        .alert(
            "Can't Delete Resident",
            isPresented: Binding(
                get: { blockedDeleteMessage != nil },
                set: { if !$0 { blockedDeleteMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(blockedDeleteMessage ?? "")
        }
    }

    private func requestDelete(_ resident: Resident) {
        let entryCount = resident.entries?.count ?? 0
        if entryCount > 0 {
            blockedDeleteMessage = """
            This resident still has \(entryCount) entr\(entryCount == 1 ? "y" : "ies") \
            referencing them. Those need to be removed first.
            """
            return
        }
        pendingDeleteResident = resident
    }

    private func performDelete(_ resident: Resident) {
        AuditEvent.log(.residentDeleted, actor: session.currentStaff, target: resident.name, in: modelContext)
        modelContext.delete(resident)
        pendingDeleteResident = nil
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
