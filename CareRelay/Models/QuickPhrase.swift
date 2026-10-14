import Foundation

enum QuickPhrase {
    static func phrases(for category: EntryCategory) -> [String] {
        switch category {
        case .safety:
            return [
                "Resident declined assistance",
                "Found on floor, no visible injury",
                "Bed rail checked and reset",
                "Wandered into another resident's room",
                "Skin check completed, no new concerns"
            ]
        case .carePlanChange:
            return [
                "Updated mobility status",
                "New dietary restriction in effect",
                "Medication time adjusted",
                "Increased assistance required for transfers",
                "Family requested care plan review"
            ]
        case .deathOrPassing:
            return [
                "Resident passed peacefully, family notified",
                "Palliative care measures in effect",
                "Funeral home contacted",
                "Room being prepared for next resident"
            ]
        case .facilityNotice:
            return [
                "Scheduled fire drill",
                "Maintenance work in common area",
                "Staff meeting reminder",
                "Visitor policy update"
            ]
        case .other:
            return [
                "Follow up needed",
                "No concerns to report",
                "See attached note for details"
            ]
        }
    }
}
