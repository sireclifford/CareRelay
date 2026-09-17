import SwiftUI
import SwiftData

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    
    let entry: Entry
    
    @State private var newCommentBody: String = ""
    
    private var currentStaff: Staff? {
        session.currentStaff
    }
    
    private var myReadReceipt: ReadReceipt? {
        entry.readReceipts?.first { $0.staff?.id == currentStaff?.id }
    }
    
    private var sortedComments: [Comment] {
        (entry.comments ?? []).sorted { $0.timestamp < $1.timestamp }
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(entry.kind == .alert ? "Alert" : "Notice")
                        .font(.headline)
                    if entry.kind == .alert, let status = entry.status {
                        Spacer()
                        Text(status == .open ? "Open" : "Resolved")
                            .foregroundStyle(status == .open ? .red : .secondary)
                    }
                }
                Text(entry.category.displayName)
                    .foregroundStyle(.secondary)
            }
            
            Section("Where") {
                Text(entry.unit?.name ?? "Facility-wide")
                if let resident = entry.resident {
                    Text(resident.name)
                }
            }
            
            Section("Details") {
                Text(entry.content)
            }
            
            Section("Author") {
                Text(entry.author?.name ?? "Unknown")
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .foregroundStyle(.secondary)
            }
            
            if entry.kind == .alert, entry.status == .open {
                Section {
                    if let role = currentStaff?.role, role.canResolveAlerts {
                        Button("Resolve") {
                            resolve()
                        }
                    } else {
                        Text("Only a nurse in charge or supervisor can resolve this.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if entry.kind == .alert, entry.status == .resolved,
               let resolvedBy = entry.resolvedBy, let resolvedAt = entry.resolvedAt {
                Section {
                    Text("Resolved by \(resolvedBy.name)")
                    Text(resolvedAt.formatted(date: .abbreviated, time: .shortened))
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Read") {
                if let receipt = myReadReceipt {
                    Text("Signed \(receipt.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                } else {
                    Button("Mark as read") {
                        markAsRead()
                    }
                }
            }
            
            if entry.kind == .alert {
                Section("Comments") {
                    ForEach(sortedComments) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.author?.name ?? "Unknown")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(comment.body)
                            Text(comment.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Add a comment", text: $newCommentBody)
                        Button("Post") {
                            addComment()
                        }
                        .disabled(newCommentBody.isEmpty)
                    }
                }
            }
        }
        .navigationTitle(entry.kind == .alert ? "Alert" : "Notice")
    }
    
    private func markAsRead() {
        guard let staff = currentStaff else { return }
        let receipt = ReadReceipt(staff: staff, entry: entry)
        modelContext.insert(receipt)
    }
    
    private func resolve() {
        guard let staff = currentStaff, staff.role.canResolveAlerts else { return }
        entry.status = .resolved
        entry.resolvedBy = staff
        entry.resolvedAt = Date()
    }
    
    private func addComment() {
        guard let staff = currentStaff, !newCommentBody.isEmpty else { return }
        let comment = Comment(entry: entry, author: staff, body: newCommentBody)
        modelContext.insert(comment)
        newCommentBody = ""
    }
}
