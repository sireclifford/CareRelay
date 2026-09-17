import SwiftUI
import SwiftData

@main
struct CareRelayApp: App {
    @State private var session = Session()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Unit.self,
            Staff.self,
            Resident.self,
            Entry.self,
            ReadReceipt.self,
            Comment.self
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
                .tint(AppColor.accent)
        }
        .modelContainer(sharedModelContainer)
        .environment(session)
    }
}
