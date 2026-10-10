import SwiftUI
import SwiftData

struct StaffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    @Query(sort: \Staff.name) private var staffMembers: [Staff]
    @State private var isPresentingAdd = false

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
                    }
                    .onDelete(perform: deleteStaff)
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
    }

    private func deleteStaff(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(staffMembers[index])
        }
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

            if staff.role.canResolveAlerts {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(AppColor.resolved)
            }
        }
    }
}
