import SwiftUI
import SwiftData

@main
struct CareRelayApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Unit.self,
            Staff.self,
            Resident.self,
            Entry.self,
            ReadReceipt.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
