import SwiftUI

struct EntryRow: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if entry.kind == .alert {
                    Label(
                        entry.status == .open ? "Open" : "Resolved",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(entry.status == .open ? .red : .secondary)
                }
                Spacer()
                Text(entry.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(entry.content)
                .font(.body)
                .lineLimit(2)
            Text(entry.author?.name ?? "Unknown")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
