import Foundation
import SwiftData

@Model
final class Resident {
    var id: UUID = UUID()
    var name: String = ""
    var unit: Unit?
    @Relationship(deleteRule: .nullify, inverse: \Entry.resident)
    var entries: [Entry]? = []
    
    init(id: UUID = UUID(), name: String, unit: Unit? = nil) {
        self.id = id
        self.name = name
        self.unit = unit
    }
}
