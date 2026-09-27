import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(Session.self) private var session
    @Query(sort: \Staff.name) private var allStaff: [Staff]
    
    var body: some View {
        NavigationStack {
            Group {
                if allStaff.isEmpty {
                    ContentUnavailableView(
                        "No Staff Found",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        description: Text("Add staff members in Roster before signing in.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(allStaff) { staff in
                                Button {
                                    session.currentStaff = staff
                                } label: {
                                    SignInRow(staff: staff)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text("Select your name to sign in for this shift.")
                        }
                    }
                }
                
            }.navigationTitle("Who's working")
        }
    }
    
    private struct SignInRow: View {
        let staff: Staff
        
        var body: some View {
            HStack(spacing: AppSpacing.medium) {
                Circle()
                    .fill(AppColor.accent.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(staff.initials)
                            .font(.headline)
                            .foregroundStyle(AppColor.accent)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(staff.name)
                        .font(.body)
                    Text(staff.role.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, AppSpacing.small / 2)
            .contentShape(Rectangle())
        }
    }
}
