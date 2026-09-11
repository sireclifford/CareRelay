import Foundation
import SwiftData

enum EntryKind: String, Codable, CaseIterable {
    case notice
    case alert
}

enum EntryCategory: String, Codable, CaseIterable {
    case safety
    case carePlanChange
    case deathOrPassing
    case facilityNotice
    case other
}

enum AlertStatus: String, Codable, CaseIterable {
    case open
    case resolved
}


@Model
final class Entry {
    var id: UUID = UUID()
    var kind: EntryKind = EntryKind.notice
    var unit: Unit?
    var resident: Resident?
    var category: EntryCategory = EntryCategory.other
    var body: String = ""
    var author: Staff?
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \ReadReceipt.entry)
    var readReceipts: [ReadReceipt]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Comment.entry)
    var comments: [Comment]? = []
    
    var status: AlertStatus?
    var resolvedBy: Staff?
    var resolvedAt: Date?
    
    init(
        id: UUID = UUID(),
        kind: EntryKind,
        unit: Unit? = nil,
        resident: Resident? = nil,
        category: EntryCategory,
        body: String,
        author: Staff?,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.kind = kind
        self.unit = unit
        self.resident = resident
        self.category = category
        self.body = body
        self.author = author
        self.createdAt = createdAt
        self.status = kind == .alert ? .open : nil
        self.resolvedBy = nil
        self.resolvedAt = nil
    }
}
