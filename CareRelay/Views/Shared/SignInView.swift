import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var allStaff: [Staff]

    @State private var pendingStaff: Staff?

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
                                    pendingStaff = staff
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
            }
            .navigationTitle("Who's working")
            .toolbar {
                #if DEBUG
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset & Seed Data") {
                        SeedData.resetAndSeed(context: modelContext)
                    }
                }
                #endif
            }
            .sheet(item: $pendingStaff) { staff in
                StaffIDPromptView(staff: staff) {
                    session.currentStaff = staff
                }
            }
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

    private struct StaffIDPromptView: View {
        let staff: Staff
        let onConfirm: () -> Void

        @Environment(\.dismiss) private var dismiss
        @State private var idInput = ""
        @State private var showsError = false

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        TextField("Staff ID number", text: $idInput)
                            .keyboardType(.numberPad)
                    } header: {
                        Text("Enter your staff ID to sign in as \(staff.name).")
                    } footer: {
                        if showsError {
                            Text("That ID number doesn't match. Try again.")
                                .foregroundStyle(AppColor.alertOpen)
                        }
                    }
                }
                .navigationTitle("Confirm ID")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirm") {
                            let trimmed = idInput.trimmingCharacters(in: .whitespaces)
                            if trimmed == staff.idNumber {
                                onConfirm()
                                dismiss()
                            } else {
                                showsError = true
                            }
                        }
                        .disabled(idInput.isEmpty)
                    }
                }
            }
        }
    }
}
