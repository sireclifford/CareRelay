import SwiftUI

struct EntryRow: View {
    let entry: Entry

    private var contextLine: String {
        var parts: [String] = []
        if let resident = entry.resident {
            parts.append(resident.name)
        }
        parts.append(entry.unit?.name ?? "Facility-wide")
        return parts.joined(separator: " · ")
    }

    private var isOpenAlert: Bool {
        entry.kind == .alert && entry.status == .open
    }

    private var iconColor: Color {
        if isOpenAlert { return AppColor.alertOpen }
        if entry.kind == .alert { return AppColor.resolved }
        return AppColor.accent
    }

    private var iconSymbol: String {
        isOpenAlert ? "exclamationmark.triangle.fill" : entry.category.icon
    }

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconSymbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(entry.category.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(iconColor)

                    if isOpenAlert {
                        Text("· Open")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.alertOpen)
                    } else if entry.kind == .alert {
                        Text("· Resolved")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.resolved)
                    }

                    Spacer()

                    Text(entry.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.content)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(contextLine)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                        Text(entry.author?.name ?? "Unknown")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, AppSpacing.small)
    }
}
