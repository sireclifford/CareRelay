import Foundation
import SwiftData

@Model
final class QuickPhrase {
    var text: String = ""
    var category: EntryCategory = EntryCategory.other
    var createdAt: Date = Date()
    
    init(text: String, category: EntryCategory, createdAt: Date = .now) {
        self.text = text
        self.category = category
        self.createdAt = createdAt
    }
}
