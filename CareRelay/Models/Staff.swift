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
    
    init(id: UUID = UUID(), name: String, role: StaffRole) {
        self.id = id
        self.name = name
        self.role = role
    }
}
