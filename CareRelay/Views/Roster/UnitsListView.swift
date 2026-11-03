import SwiftUI
import SwiftData

struct UnitsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    @Query(sort: \Unit.name) private var units: [Unit]
    @State private var isPresentingAdd = false
    @State private var pendingDeleteUnit: Unit?
    @State private var blockedDeleteMessage: String?

    private var canManage: Bool {
        session.currentStaff?.role.canManageRoster ?? false
    }

    private var emptyStateDescription: String {
        canManage ? "Tap the + button to add your first unit." : "Units will appear here once added."
    }

    var body: some View {
        Group {
            if units.isEmpty {
                ContentUnavailableView(
                    "No Units Yet",
                    systemImage: "building.2",
                    description: Text(emptyStateDescription)
                )
            } else if canManage {
                List {
                    ForEach(units) { unit in
                        UnitRow(unit: unit)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    requestDelete(unit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            } else {
                List {
                    ForEach(units) { unit in
                        UnitRow(unit: unit)
                    }
                }
            }
        }
        .navigationTitle("Units")
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
            AddUnitView()
        }
        .confirmationDialog(
            "Delete this unit?",
            isPresented: Binding(
                get: { pendingDeleteUnit != nil },
                set: { if !$0 { pendingDeleteUnit = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDeleteUnit
        ) { unit in
            Button("Delete \(unit.name)", role: .destructive) {
                performDelete(unit)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This can't be undone.")
        }
        .alert(
            "Can't Delete Unit",
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

    private func requestDelete(_ unit: Unit) {
        let residentCount = unit.residents?.count ?? 0
        let entryCount = unit.entries?.count ?? 0
        if residentCount > 0 || entryCount > 0 {
            blockedDeleteMessage = """
            This unit still has \(residentCount) resident\(residentCount == 1 ? "" : "s") \
            and \(entryCount) entr\(entryCount == 1 ? "y" : "ies") linked to it. \
            Move or delete those first.
            """
            return
        }
        pendingDeleteUnit = unit
    }

    private func performDelete(_ unit: Unit) {
        AuditEvent.log(.unitDeleted, actor: session.currentStaff, target: unit.name, in: modelContext)
        modelContext.delete(unit)
        pendingDeleteUnit = nil
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
