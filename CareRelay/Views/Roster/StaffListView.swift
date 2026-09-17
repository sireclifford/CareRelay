import SwiftUI
import SwiftData

struct StaffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var staffMembers: [Staff]
    @State private var isPresentingAdd = false

    var body: some View {
        Group {
            if staffMembers.isEmpty {
                ContentUnavailableView(
                    "No Staff Yet",
                    systemImage: "person.3",
                    description: Text("Tap the + button to add your first staff member.")
                )
            } else {
                List {
                    ForEach(staffMembers) { staff in
                        StaffRow(staff: staff)
                    }
                    .onDelete(perform: deleteStaff)
                }
            }
        }
        .navigationTitle("Staff")
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
