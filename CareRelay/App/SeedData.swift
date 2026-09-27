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

        let cedar = Unit(name: "Cedar")
        let manor = Unit(name: "Manor")
        let redwood = Unit(name: "Redwood")
        [cedar, manor, redwood].forEach { context.insert($0) }

        let alvin = Staff(name: "Alvin Mensah", role: .caregiver)
        let esther = Staff(name: "Esther Okafor", role: .nurseInCharge)
        let jessica = Staff(name: "Jessica Tremblay", role: .supervisor)
        let kaylee = Staff(name: "Kaylee Bishop", role: .nurseInCharge)
        let laurence = Staff(name: "Laurence Adeyemi", role: .caregiver)
        let shawna = Staff(name: "Shawna Whitehorse", role: .supervisor)
        [alvin, esther, jessica, kaylee, laurence, shawna].forEach { context.insert($0) }

        let angeline = Resident(name: "Angeline Smith", unit: cedar)
        let bernard = Resident(name: "Bernard Cho", unit: cedar)
        let clara = Resident(name: "Clara Dupont", unit: manor)
        let derek = Resident(name: "Derek Osei", unit: manor)
        let ella = Resident(name: "Ella Fontaine", unit: redwood)
        let felix = Resident(name: "Felix Ngata", unit: redwood)
        [angeline, bernard, clara, derek, ella, felix].forEach { context.insert($0) }

        func days(_ n: Double) -> Date { Date().addingTimeInterval(-n * 86_400) }
        func hours(_ n: Double) -> Date { Date().addingTimeInterval(-n * 3_600) }

        // 1: Notice, unit + resident, already read by one staff member
        let entry1 = Entry(
            kind: .notice,
            unit: cedar,
            resident: angeline,
            category: .safety,
            content: "Angeline's bed rail was left down after the 2pm round. Please double check before leaving her room.",
            author: alvin,
            createdAt: days(6)
        )
        context.insert(entry1)
        context.insert(ReadReceipt(staff: esther, entry: entry1, timestamp: days(5)))

        // 2: Notice, facility-wide, no resident
        let entry2 = Entry(
            kind: .notice,
            unit: nil,
            resident: nil,
            category: .facilityNotice,
            content: "Fire drill scheduled for Thursday at 10am. All units should review evacuation routes with residents beforehand.",
            author: jessica,
            createdAt: days(4)
        )
        context.insert(entry2)

        // 3: Notice, care plan change, read by two staff
        let entry3 = Entry(
            kind: .notice,
            unit: manor,
            resident: clara,
            category: .carePlanChange,
            content: "Clara's care plan updated — she now requires a mechanical lift for all transfers, not just assisted standing.",
            author: kaylee,
            createdAt: days(3)
        )
        context.insert(entry3)
        context.insert(ReadReceipt(staff: laurence, entry: entry3, timestamp: days(2)))
        context.insert(ReadReceipt(staff: alvin, entry: entry3, timestamp: days(1)))

        // 4: Notice, unit-specific, no resident, unread
        let entry4 = Entry(
            kind: .notice,
            unit: redwood,
            resident: nil,
            category: .other,
            content: "New hand sanitizer dispensers installed outside every resident room on Redwood.",
            author: shawna,
            createdAt: hours(20)
        )
        context.insert(entry4)

        // 5: Notice, death/passing category, unread
        let entry5 = Entry(
            kind: .notice,
            unit: manor,
            resident: derek,
            category: .deathOrPassing,
            content: "Derek's family has been notified of his declining condition. Palliative care team is now involved.",
            author: esther,
            createdAt: hours(10)
        )
        context.insert(entry5)

        // 6: Open Alert, with a two-comment thread and one read receipt
        let entry6 = Entry(
            kind: .alert,
            unit: cedar,
            resident: bernard,
            category: .safety,
            content: "Bernard had a fall near the bathroom this morning. No visible injury, but he should be monitored closely for the next 24 hours.",
            author: alvin,
            createdAt: hours(6)
        )
        context.insert(entry6)
        context.insert(ReadReceipt(staff: esther, entry: entry6, timestamp: hours(5)))
        context.insert(Comment(entry: entry6, author: esther, body: "Checked at 1pm, resting comfortably. No further symptoms.", timestamp: hours(5)))
        context.insert(Comment(entry: entry6, author: jessica, body: "Family notified. Will follow up again this evening.", timestamp: hours(2)))

        // 7: Open Alert, facility-wide, no comments yet — tests the empty comment state
        let entry7 = Entry(
            kind: .alert,
            unit: nil,
            resident: nil,
            category: .carePlanChange,
            content: "Kitchen reports a facility-wide shortage of thickened-liquid supplies. Please ration use until the next delivery.",
            author: kaylee,
            createdAt: hours(3)
        )
        context.insert(entry7)

        // 8: Resolved Alert, with a comment left before it closed out
        let entry8 = Entry(
            kind: .alert,
            unit: redwood,
            resident: ella,
            category: .deathOrPassing,
            content: "Ella passed away peacefully overnight with family present. Please refer new staff to the current end-of-life protocol.",
            author: shawna,
            createdAt: days(2)
        )
        entry8.status = .resolved
        entry8.resolvedBy = jessica
        entry8.resolvedAt = days(1)
        context.insert(entry8)
        context.insert(Comment(entry: entry8, author: jessica, body: "Family has left the building. Room to be prepared for next admission per protocol.", timestamp: days(1)))

        // 9: Resolved Alert, facility-wide, no comments
        let entry9 = Entry(
            kind: .alert,
            unit: nil,
            resident: nil,
            category: .facilityNotice,
            content: "Water main break affected hot water on the east wing for several hours yesterday. Now fully restored.",
            author: laurence,
            createdAt: days(1)
        )
        entry9.status = .resolved
        entry9.resolvedBy = kaylee
        entry9.resolvedAt = hours(18)
        context.insert(entry9)

        // 10: Open Alert, completely fresh — the newest, most-untouched item
        let entry10 = Entry(
            kind: .alert,
            unit: manor,
            resident: derek,
            category: .other,
            content: "Derek has been refusing meals for the past two shifts. Needs a care plan review as soon as possible.",
            author: esther,
            createdAt: hours(1)
        )
        context.insert(entry10)
    }

    private static func deleteAll<T: PersistentModel>(_ type: T.Type, in context: ModelContext) {
        if let objects = try? context.fetch(FetchDescriptor<T>()) {
            for object in objects {
                context.delete(object)
            }
        }
    }
}
