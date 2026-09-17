import SwiftUI
import SwiftData

struct RosterView: View {
    @Environment(Session.self) private var session

    @Query private var units: [Unit]
    @Query private var staffMembers: [Staff]
    @Query private var residents: [Resident]

    var body: some View {
        List {
            if let staff = session.currentStaff {
                Section {
                    HStack(spacing: AppSpacing.medium) {
                        ZStack {
                            Circle()
                                .fill(AppColor.accent.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Text(staff.initials)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColor.accent)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(staff.name)
                                .font(.subheadline.weight(.semibold))
                            Text(staff.role.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button("Switch") {
                            session.currentStaff = nil
                        }
                        .font(.subheadline)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section("Manage") {
                NavigationLink {
                    UnitsListView()
                } label: {
                    RosterMenuRow(icon: "building.2.fill", title: "Units", count: units.count)
                }

                NavigationLink {
                    StaffListView()
                } label: {
                    RosterMenuRow(icon: "person.3.fill", title: "Staff", count: staffMembers.count)
                }

                NavigationLink {
                    ResidentsListView()
                } label: {
                    RosterMenuRow(icon: "bed.double.fill", title: "Residents", count: residents.count)
                }
            }
        }
        .navigationTitle("Roster")
    }
}

private struct RosterMenuRow: View {
    let icon: String
    let title: String
    let count: Int

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColor.accent.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }

            Text(title)

            Spacer()

            Text("\(count)")
                .foregroundStyle(.secondary)
        }
    }
}
