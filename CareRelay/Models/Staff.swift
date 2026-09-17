enum StaffRole: String, Codable, CaseIterable {
    case caregiver
    case nurseInCharge
    case supervisor

    var canResolveAlerts: Bool {
        switch self {
        case .caregiver:
            return false
        case .nurseInCharge, .supervisor:
            return true
        }
    }

    var displayName: String {
        switch self {
        case .caregiver: return "Caregiver"
        case .nurseInCharge: return "Nurse in Charge"
        case .supervisor: return "Supervisor"
        }
    }
}

import Foundation
import SwiftData

@Model
final class Staff {
    var id: UUID = UUID()
    var name: String = ""
    var role: StaffRole = StaffRole.caregiver

    @Relationship(deleteRule: .nullify, inverse: \Entry.author)
    var authoredEntries: [Entry]? = []

    @Relationship(deleteRule: .nullify, inverse: \Entry.resolvedBy)
    var resolvedEntries: [Entry]? = []

    @Relationship(deleteRule: .nullify, inverse: \ReadReceipt.staff)
    var readReceipts: [ReadReceipt]? = []

    @Relationship(deleteRule: .nullify, inverse: \Comment.author)
    var comments: [Comment]? = []
    
    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    init(id: UUID = UUID(), name: String, role: StaffRole) {
        self.id = id
        self.name = name
        self.role = role
    }
}
