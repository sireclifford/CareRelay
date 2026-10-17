import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(Session.self) private var session
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var allStaff: [Staff]
    
    @State private var pendingStaff: Staff?
    @State private var searchText = ""
    
    private var filteredStaff: [Staff] {
        guard !searchText.isEmpty else {return allStaff}
        return allStaff.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var staffByRole: [(role: StaffRole, staff: [Staff])] {
        StaffRole.allCases.compactMap {role in
            let matches = filteredStaff.filter { $0.role == role }
            return matches.isEmpty ? nil : (role, matches)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if allStaff.isEmpty {
                    ContentUnavailableView {
                        Label("No Staff Found", systemImage: "person.crop.circle.badge.exclamationmark")
                    } description: {
                        Text("Add staff members in Roster, or set up starter data to get going right away.")
                    } actions: {
                        Button("Set Up Starter Data") {
                            SeedData.seedIfEmpty(context: modelContext)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(staffByRole, id: \.role) { group in
                            Section {
                                ForEach(group.staff) { staff in
                                    Button {
                                        pendingStaff = staff
                                    } label: {
                                        SignInRow(staff: staff)
                                    }
                                    .buttonStyle(.plain)
                                }
                            } header: {
                                Text(group.role.displayName)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search staff")
                    .overlay {
                        if staffByRole.isEmpty {
                            ContentUnavailableView(
                                "No Results",
                                systemImage: "magnifyingglass",
                                description: Text("No staff found matching \"\(searchText)\".")
                            )
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
        @FocusState private var isIDFieldFocused: Bool
        
        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        TextField("Staff ID number", text: $idInput)
                            .keyboardType(.numberPad)
                            .focused($isIDFieldFocused)
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
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    onConfirm()
                                }
                            } else {
                                showsError = true
                            }
                        }
                        .disabled(idInput.isEmpty)
                    }
                }
                .onAppear {
                    isIDFieldFocused = true
                }
            }
        }
    }
}
