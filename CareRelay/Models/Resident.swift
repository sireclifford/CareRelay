import Foundation
import SwiftData

@Model
final class Resident {
    var id: UUID = UUID()
    var name: String = ""
    var unit: Unit?
    
    init(id: UUID = UUID(), name: String, unit: Unit? = nil) {
        self.id = id
        self.name = name
        self.unit = unit
    }
}
