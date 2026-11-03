import Foundation
import SwiftData

enum AuditAction: String, Codable, CaseIterable {
    case staffDeactivated
    case unitDeleted
    case residentDeleted
    case entryEdited
    case unknown

    var displayName: String {
        switch self {
        case .staffDeactivated: return "Staff Deactivated"
        case .unitDeleted: return "Unit Deleted"
        case .residentDeleted: return "Resident Deleted"
        case .entryEdited: return "Entry Edited"
        case .unknown: return "Unknown"
        }
    }
}

@Model
final class AuditEvent {
    var id: UUID = UUID()
    var actionRaw: String = AuditAction.unknown.rawValue
    var actorName: String = ""
    var targetDescription: String = ""
    var timestamp: Date = Date()

    var action: AuditAction {
        AuditAction(rawValue: actionRaw) ?? .unknown
    }

    init(
        id: UUID = UUID(),
        action: AuditAction,
        actorName: String,
        targetDescription: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.actionRaw = action.rawValue
        self.actorName = actorName
        self.targetDescription = targetDescription
        self.timestamp = timestamp
    }
}

extension AuditEvent {
    @discardableResult
    static func log(
        _ action: AuditAction,
        actor: Staff?,
        target: String,
        in context: ModelContext
    ) -> AuditEvent {
        let event = AuditEvent(
            action: action,
            actorName: actor?.name ?? "Unknown",
            targetDescription: target
        )
        context.insert(event)
        return event
    }
}
