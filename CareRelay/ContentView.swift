import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Label("Feed", systemImage: "list.bullet")
            }

            NavigationStack {
                RosterView()
            }
            .tabItem {
                Label("Roster", systemImage: "person.3")
            }
        }
    }
}
