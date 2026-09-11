import Foundation
import SwiftData

@Model
final class ReadReceipt {
    var id: UUID = UUID()
    var staff: Staff?
    var entry: Entry?
    var timestamp: Date = Date()
    var reaction: String?
    
    init(id: UUID = UUID(), staff: Staff?, entry: Entry?, timestamp: Date = Date(), reaction: String? = nil){
        self.id = id
        self.staff = staff
        self.entry = entry
        self.timestamp = timestamp
        self.reaction = reaction
    }
}
