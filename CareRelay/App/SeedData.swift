import Foundation
import SwiftData

enum SeedData {
    static func resetAndSeed(context: ModelContext) {
        deleteAll(Entry.self, in: context)
        deleteAll(Comment.self, in: context)
        deleteAll(ReadReceipt.self, in: context)
        deleteAll(Resident.self, in: context)
        deleteAll(Staff.self, in: context)
        deleteAll(Unit.self, in: context)
        deleteAll(QuickPhrase.self, in: context)

        let cedar = Unit(name: "Cedar")
        let manor = Unit(name: "Manor")
        let redwood = Unit(name: "Redwood")
        [cedar, manor, redwood].forEach { context.insert($0) }

        let phraseSeeds: [(EntryCategory, [String])] = [
            (.safety, [
                "Resident declined assistance",
                "Found on floor, no visible injury",
                "Bed rail checked and reset",
                "Wandered into another resident's room",
                "Skin check completed, no new concerns"
            ]),
            (.carePlanChange, [
                "Updated mobility status",
                "New dietary restriction in effect",
                "Medication time adjusted",
                "Increased assistance required for transfers",
                "Family requested care plan review"
            ]),
            (.deathOrPassing, [
                "Resident passed peacefully, family notified",
                "Palliative care measures in effect",
                "Funeral home contacted",
                "Room being prepared for next resident"
            ]),
            (.facilityNotice, [
                "Scheduled fire drill",
                "Maintenance work in common area",
                "Staff meeting reminder",
                "Visitor policy update"
            ]),
            (.other, [
                "Follow up needed",
                "No concerns to report",
                "See attached note for details"
            ])
        ]
        var phraseOffset = 0.0
        for (category, phrases) in phraseSeeds {
            for text in phrases {
                context.insert(QuickPhrase(text: text, category: category, createdAt: Date().addingTimeInterval(phraseOffset)))
                phraseOffset += 1
            }
        }

        let marcus = Staff(name: "Marcus Webb", role: .caregiver, idNumber: "1234")
        let priya = Staff(name: "Priya Sharma", role: .caregiver, idNumber: "1234")
        let devon = Staff(name: "Devon Walsh", role: .caregiver, idNumber: "1234")
        let natalie = Staff(name: "Natalie Brooks", role: .caregiver, idNumber: "1234")
        let samuel = Staff(name: "Samuel Okoye", role: .caregiver, idNumber: "1234")
        let renata = Staff(name: "Renata Silva", role: .nurseInCharge, idNumber: "1234")
        let tobias = Staff(name: "Tobias Lindqvist", role: .nurseInCharge, idNumber: "1234")
        let monica = Staff(name: "Monica Ferreira", role: .nurseInCharge, idNumber: "1234")
        let daniel = Staff(name: "Daniel Kim", role: .supervisor, idNumber: "1234")
        let harriet = Staff(name: "Harriet Boone", role: .supervisor, idNumber: "1234")
        [marcus, priya, devon, natalie, samuel, renata, tobias, monica, daniel, harriet].forEach { context.insert($0) }

        let opal = Resident(name: "Opal Jennings", unit: cedar)
        let frederick = Resident(name: "Frederick Diallo", unit: cedar)
        let mabel = Resident(name: "Mabel Reyes", unit: cedar)
        let theodore = Resident(name: "Theodore Lindgren", unit: cedar)
        let patricia = Resident(name: "Patricia Kowalski", unit: manor)
        let victor = Resident(name: "Victor Amadi", unit: manor)
        let rosalind = Resident(name: "Rosalind Finch", unit: manor)
        let benedict = Resident(name: "Benedict Petrov", unit: manor)
        let loretta = Resident(name: "Loretta Humphries", unit: redwood)
        let gideon = Resident(name: "Gideon Castellanos", unit: redwood)
        let agnes = Resident(name: "Agnes Whitfield", unit: redwood)
        let elmer = Resident(name: "Elmer Novak", unit: redwood)
        [opal, frederick, mabel, theodore, patricia, victor, rosalind, benedict, loretta, gideon, agnes, elmer].forEach { context.insert($0) }

        func days(_ n: Double) -> Date { Date().addingTimeInterval(-n * 86_400) }
        func hours(_ n: Double) -> Date { Date().addingTimeInterval(-n * 3_600) }

        // 1: Notice, unit + resident, already read by one staff member
        let entry1 = Entry(
            kind: .notice,
            unit: cedar,
            resident: opal,
            category: .safety,
            content: "Opal's bed rail was left down after the 2pm round. Please double check before leaving her room.",
            author: marcus,
            createdAt: days(6)
        )
        context.insert(entry1)
        context.insert(ReadReceipt(staff: renata, entry: entry1, timestamp: days(5)))

        // 2: Notice, facility-wide, no resident
        let entry2 = Entry(
            kind: .notice,
            unit: nil,
            resident: nil,
            category: .facilityNotice,
            content: "Fire drill scheduled for Thursday at 10am. All units should review evacuation routes with residents beforehand.",
            author: daniel,
            createdAt: days(4)
        )
        context.insert(entry2)

        // 3: Notice, care plan change, read by two staff
        let entry3 = Entry(
            kind: .notice,
            unit: manor,
            resident: patricia,
            category: .carePlanChange,
            content: "Patricia's care plan updated — she now requires a mechanical lift for all transfers, not just assisted standing.",
            author: tobias,
            createdAt: days(3)
        )
        context.insert(entry3)
        context.insert(ReadReceipt(staff: natalie, entry: entry3, timestamp: days(2)))
        context.insert(ReadReceipt(staff: marcus, entry: entry3, timestamp: days(1)))

        // 4: Notice, unit-specific, no resident, unread
        let entry4 = Entry(
            kind: .notice,
            unit: redwood,
            resident: nil,
            category: .other,
            content: "New hand sanitizer dispensers installed outside every resident room on Redwood.",
            author: harriet,
            createdAt: hours(20)
        )
        context.insert(entry4)

        // 5: Notice, death/passing category, unread
        let entry5 = Entry(
            kind: .notice,
            unit: manor,
            resident: victor,
            category: .deathOrPassing,
            content: "Victor's family has been notified of his declining condition. Palliative care team is now involved.",
            author: renata,
            createdAt: hours(10)
        )
        context.insert(entry5)

        // 6: Open Alert, with a two-comment thread and one read receipt
        let entry6 = Entry(
            kind: .alert,
            unit: cedar,
            resident: frederick,
            category: .safety,
            content: "Frederick had a fall near the bathroom this morning. No visible injury, but he should be monitored closely for the next 24 hours.",
            author: priya,
            createdAt: hours(6)
        )
        context.insert(entry6)
        context.insert(ReadReceipt(staff: renata, entry: entry6, timestamp: hours(5)))
        context.insert(Comment(entry: entry6, author: renata, body: "Checked at 1pm, resting comfortably. No further symptoms.", timestamp: hours(5)))
        context.insert(Comment(entry: entry6, author: daniel, body: "Family notified. Will follow up again this evening.", timestamp: hours(2)))

        // 7: Open Alert, facility-wide, no comments yet — tests the empty comment state
        let entry7 = Entry(
            kind: .alert,
            unit: nil,
            resident: nil,
            category: .carePlanChange,
            content: "Kitchen reports a facility-wide shortage of thickened-liquid supplies. Please ration use until the next delivery.",
            author: monica,
            createdAt: hours(3)
        )
        context.insert(entry7)

        // 8: Resolved Alert, with a comment left before it closed out
        let entry8 = Entry(
            kind: .alert,
            unit: redwood,
            resident: loretta,
            category: .deathOrPassing,
            content: "Loretta passed away peacefully overnight with family present. Please refer new staff to the current end-of-life protocol.",
            author: harriet,
            createdAt: days(2)
        )
        entry8.status = .resolved
        entry8.resolvedBy = daniel
        entry8.resolvedAt = days(1)
        context.insert(entry8)
        context.insert(Comment(entry: entry8, author: daniel, body: "Family has left the building. Room to be prepared for next admission per protocol.", timestamp: days(1)))

        // 9: Resolved Alert, facility-wide, no comments
        let entry9 = Entry(
            kind: .alert,
            unit: nil,
            resident: nil,
            category: .facilityNotice,
            content: "Water main break affected hot water on the east wing for several hours yesterday. Now fully restored.",
            author: devon,
            createdAt: days(1)
        )
        entry9.status = .resolved
        entry9.resolvedBy = monica
        entry9.resolvedAt = hours(18)
        context.insert(entry9)

        // 10: Open Alert, newest among the original scenario set
        let entry10 = Entry(
            kind: .alert,
            unit: manor,
            resident: victor,
            category: .other,
            content: "Victor has been refusing meals for the past two shifts. Needs a care plan review as soon as possible.",
            author: tobias,
            createdAt: hours(1)
        )
        context.insert(entry10)

        // 11: Notice, unit + resident, safety, read by one staff member
        let entry11 = Entry(
            kind: .notice,
            unit: cedar,
            resident: mabel,
            category: .safety,
            content: "Mabel reported dizziness after breakfast. Vitals checked on the spot and came back stable.",
            author: samuel,
            createdAt: days(5)
        )
        context.insert(entry11)
        context.insert(ReadReceipt(staff: renata, entry: entry11, timestamp: days(4)))

        // 12: Notice, care plan change, unread
        let entry12 = Entry(
            kind: .notice,
            unit: manor,
            resident: rosalind,
            category: .carePlanChange,
            content: "Rosalind's physio sessions increased to twice daily per her updated care plan.",
            author: monica,
            createdAt: days(4.5)
        )
        context.insert(entry12)

        // 13: Notice, unit + resident, other, unread
        let entry13 = Entry(
            kind: .notice,
            unit: redwood,
            resident: gideon,
            category: .other,
            content: "Gideon's family requested extra visiting hours this week for a birthday celebration.",
            author: natalie,
            createdAt: days(2.3)
        )
        context.insert(entry13)

        // 14: Notice, facility-wide, read by two staff
        let entry14 = Entry(
            kind: .notice,
            unit: nil,
            resident: nil,
            category: .facilityNotice,
            content: "New visitor sign-in sheets are now required at every unit entrance.",
            author: daniel,
            createdAt: hours(36)
        )
        context.insert(entry14)
        context.insert(ReadReceipt(staff: samuel, entry: entry14, timestamp: hours(30)))
        context.insert(ReadReceipt(staff: devon, entry: entry14, timestamp: hours(24)))

        // 15: Open Alert, with a single comment
        let entry15 = Entry(
            kind: .alert,
            unit: cedar,
            resident: theodore,
            category: .safety,
            content: "Theodore attempted to leave through the fire exit unassisted. Door alarm triggered, redirected safely.",
            author: priya,
            createdAt: hours(14)
        )
        context.insert(entry15)
        context.insert(Comment(entry: entry15, author: renata, body: "Spoke with Theodore, agitation related to a recent room change. Monitoring closely.", timestamp: hours(12)))

        // 16: Resolved Alert, with a comment left before it closed out
        let entry16 = Entry(
            kind: .alert,
            unit: manor,
            resident: benedict,
            category: .carePlanChange,
            content: "Benedict's swallowing assessment flagged a choking risk. Diet modified to pureed pending follow-up.",
            author: tobias,
            createdAt: days(3.5)
        )
        entry16.status = .resolved
        entry16.resolvedBy = harriet
        entry16.resolvedAt = days(2.5)
        context.insert(entry16)
        context.insert(Comment(entry: entry16, author: harriet, body: "Kitchen notified, new diet card posted in Benedict's room.", timestamp: days(2.5)))

        // 17: Notice, unit + resident, other, unread
        let entry17 = Entry(
            kind: .notice,
            unit: redwood,
            resident: agnes,
            category: .other,
            content: "Agnes's family is visiting from out of province this weekend — please accommodate extra chairs in her room.",
            author: monica,
            createdAt: hours(9)
        )
        context.insert(entry17)

        // 18: Open Alert, facility-wide, completely fresh — the newest, most-untouched item
        let entry18 = Entry(
            kind: .alert,
            unit: nil,
            resident: nil,
            category: .safety,
            content: "Wet floor near the Manor nursing station. Caution signs placed, awaiting maintenance for a permanent fix.",
            author: devon,
            createdAt: hours(0.5)
        )
        context.insert(entry18)
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) {
        if let objects = try? context.fetch(FetchDescriptor<T>()) {
            for object in objects {
                context.delete(object)
            }
        }
    }
}
