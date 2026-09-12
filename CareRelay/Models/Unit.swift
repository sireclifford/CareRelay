import Foundation
import SwiftData

@Model
final class Unit {
    var id: UUID = UUID()
    var name: String = ""
    @Relationship(deleteRule: .nullify, inverse: \Resident.unit)
    var residents: [Resident]? = []
    @Relationship(deleteRule: .nullify, inverse: \Entry.unit)
    var entries: [Entry]? = []

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

