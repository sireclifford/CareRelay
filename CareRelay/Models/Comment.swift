import Foundation
import SwiftData

@Model
final class Comment {
    var id: UUID = UUID()
    var entry: Entry?
    var author: Staff?
    var body: String = ""
    var timestamp: Date = Date()
    
    init(id: UUID = UUID(), entry: Entry?, author: Staff?, body: String, timestamp: Date = Date()){
        self.id = id
        self.entry = entry
        self.author = author
        self.body = body
        self.timestamp = timestamp
    }
}
