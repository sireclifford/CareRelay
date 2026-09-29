import SwiftUI
import SwiftData

private let quickReactions = ["👍", "❤️", "🙏", "😢", "😮"]

struct EntryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Session.self) private var session
    
    let entry: Entry
    
    @State private var newCommentBody: String = ""
    @State private var isShowingReactionPicker = false
    
    private var currentStaff: Staff? {
        session.currentStaff
    }
    
    private var myReadReceipt: ReadReceipt? {
        entry.readReceipt(for: currentStaff)
    }
    
    private var sortedComments: [Comment] {
        (entry.comments ?? []).sorted { $0.timestamp < $1.timestamp }
    }
    
    private var trimmedComment: String {
        newCommentBody.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var headerTint: Color {
        guard entry.kind == .alert else { return AppColor.accent }
        return entry.status == .resolved ? AppColor.resolved : AppColor.alertOpen
    }
    
    var body: some View {
        Form {
            Section {
                HStack(spacing: AppSpacing.medium) {
                    Circle()
                        .fill(headerTint.opacity(0.15))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: entry.category.icon)
                                .foregroundStyle(headerTint)
                        }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.category.displayName)
                            .font(.headline)
                        Text(entry.kind == .alert ? "Alert" : "Notice")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if entry.kind == .alert, let status = entry.status {
                        StatusBadge(status: status)
                    }
                }
                .padding(.vertical, AppSpacing.small / 2)
            }
            
            Section("Where") {
                Label(entry.unit?.name ?? "Facility-wide", systemImage: "building.2.fill")
                    .foregroundStyle(.secondary)
                if let resident = entry.resident {
                    Label(resident.name, systemImage: "person.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Text(entry.content)
                
                if !entry.reactionCounts.isEmpty {
                    ReactionSummaryRow(counts: entry.reactionCounts)
                }
                
            } header: {
                HStack {
                    Text("Details")
                    Spacer()
                    if let receipt = myReadReceipt {
                        Button {
                            isShowingReactionPicker = true
                        } label: {
                            Image(systemName: "face.smiling")
                        }
                        .popover(isPresented: $isShowingReactionPicker) {
                            ReactionPickerOverlay(receipt: receipt, isPresented: $isShowingReactionPicker)
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                }
            }
            
            Section("Author") {
                PersonRow(name: entry.author?.name, initials: entry.author?.initials, date: entry.createdAt)
            }
            
            if entry.kind == .alert, entry.status == .open {
                Section {
                    if let role = currentStaff?.role, role.canResolveAlerts {
                        Button {
                            resolve()
                        } label: {
                            Label("Mark as resolved", systemImage: "checkmark.circle")
                        }
                    } else {
                        Text("Only a nurse in charge or supervisor can resolve this.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if entry.kind == .alert, entry.status == .resolved,
               let resolvedBy = entry.resolvedBy, let resolvedAt = entry.resolvedAt {
                Section("Resolved") {
                    PersonRow(name: resolvedBy.name, initials: resolvedBy.initials, date: resolvedAt)
                }
            }
            
            Section("Read") {
                if let receipt = myReadReceipt {
                    Label(
                        "Signed \(receipt.timestamp.formatted(date: .abbreviated, time: .shortened))",
                        systemImage: "checkmark.seal.fill"
                    )
                    .foregroundStyle(AppColor.resolved)
                    
                } else {
                    Button {
                        markAsRead()
                    } label: {
                        Label("Mark as read", systemImage: "checkmark.circle")
                    }
                }
            }
            
            if entry.kind == .alert {
                Section("Comments") {
                    if sortedComments.isEmpty {
                        Text("No comments yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(sortedComments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    
                    HStack {
                        TextField("Add a comment", text: $newCommentBody)
                        Button("Post") {
                            addComment()
                        }
                        .disabled(trimmedComment.isEmpty)
                    }
                }
            }
        }
        .navigationTitle(entry.kind == .alert ? "Alert" : "Notice")
        .navigationBarTitleDisplayMode(.inline)
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
        guard let staff = currentStaff, !trimmedComment.isEmpty else { return }
        let comment = Comment(entry: entry, author: staff, body: trimmedComment)
        modelContext.insert(comment)
        newCommentBody = ""
    }
}

private struct StatusBadge: View {
    let status: AlertStatus
    
    var body: some View {
        Text(status == .open ? "Open" : "Resolved")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(status == .open ? AppColor.alertOpen : AppColor.resolved)
            .padding(.horizontal, AppSpacing.small)
            .padding(.vertical, 4)
            .background(
                Capsule().fill((status == .open ? AppColor.alertOpen : AppColor.resolved).opacity(0.15))
            )
    }
}

private struct PersonRow: View {
    let name: String?
    let initials: String?
    let date: Date
    
    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Circle()
                .fill(AppColor.accent.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Text(initials ?? "?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.accent)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name ?? "Unknown")
                Text(date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Circle()
                .fill(AppColor.accent.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay {
                    Text(comment.author?.initials ?? "?")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.accent)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.author?.name ?? "Unknown")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(comment.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(comment.body)
            }
        }
        .padding(.vertical, AppSpacing.small / 2)
    }
}

private struct ReactionPicker: View {
    let receipt: ReadReceipt
    
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(quickReactions, id: \.self) { emoji in
                Button {
                    receipt.reaction = (receipt.reaction == emoji) ? nil : emoji
                } label: {
                    Text(emoji)
                        .font(.title2)
                        .padding(8)
                        .background(
                            Circle().fill(receipt.reaction == emoji ? AppColor.accent.opacity(0.15) : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ReactionPickerOverlay: View {
    let receipt: ReadReceipt
    @Binding var isPresented: Bool

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(quickReactions, id: \.self) { emoji in
                Button {
                    receipt.reaction = (receipt.reaction == emoji) ? nil : emoji
                    isPresented = false
                } label: {
                    Text(emoji)
                        .font(.title2)
                        .padding(8)
                        .background(
                            Circle().fill(receipt.reaction == emoji ? AppColor.accent.opacity(0.15) : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.small)
    }
}

private struct ReactionSummaryRow: View {
    let counts: [(reaction: String, count: Int)]
    
    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(counts, id: \.reaction) { item in
                Text("\(item.reaction) \(item.count)")
                    .font(.caption)
                    .padding(.horizontal, AppSpacing.small)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(AppColor.accent.opacity(0.15)))
            }
        }
    }
}
