import SwiftUI
import SwiftData

struct StaffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    @Query(sort: \Staff.name) private var staffMembers: [Staff]
    @State private var isPresentingAdd = false
    @State private var pendingDeactivateStaff: Staff?

    private var canManage: Bool {
        session.currentStaff?.role.canManageRoster ?? false
    }

    private var emptyStateDescription: String {
        canManage ? "Tap the + button to add your first staff member." : "Staff will appear here once added."
    }

    var body: some View {
        Group {
            if staffMembers.isEmpty {
                ContentUnavailableView(
                    "No Staff Yet",
                    systemImage: "person.3",
                    description: Text(emptyStateDescription)
                )
            } else if canManage {
                List {
                    ForEach(staffMembers) { staff in
                        StaffRow(staff: staff)
                            .swipeActions(edge: .trailing) {
                                if staff.isActive {
                                    Button {
                                        pendingDeactivateStaff = staff
                                    } label: {
                                        Label("Deactivate", systemImage: "person.fill.xmark")
                                    }
                                } else {
                                    Button {
                                        staff.isActive = true
                                    } label: {
                                        Label("Reactivate", systemImage: "person.fill.checkmark")
                                    }
                                    .tint(.green)
                                }
                            }
                    }
                }
            } else {
                List {
                    ForEach(staffMembers) { staff in
                        StaffRow(staff: staff)
                    }
                }
            }
        }
        .navigationTitle("Staff")
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
            AddStaffView()
        }
        .confirmationDialog(
            "Deactivate this staff member?",
            isPresented: Binding(
                get: { pendingDeactivateStaff != nil },
                set: { if !$0 { pendingDeactivateStaff = nil } }
            ),
            titleVisibility: .visible,
            presenting: pendingDeactivateStaff
        ) { staff in
            Button("Deactivate \(staff.name)", role: .destructive) {
                deactivate(staff)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("They'll be hidden from sign-in. Entries they already wrote stay as they are.")
        }
    }

    private func deactivate(_ staff: Staff) {
        AuditEvent.log(.staffDeactivated, actor: session.currentStaff, target: staff.name, in: modelContext)
        staff.isActive = false
        pendingDeactivateStaff = nil
    }
}

private struct StaffRow: View {
    let staff: Staff

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColor.accent.opacity(0.15))
                    .frame(width: 40, height: 40)
                Text(staff.initials)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(staff.name)
                Text(staff.role.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !staff.isActive {
                Text("Inactive")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else if staff.role.canResolveAlerts {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(AppColor.resolved)
            }
        }
        .opacity(staff.isActive ? 1 : 0.5)
    }
}
