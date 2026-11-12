import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @Environment(Session.self) private var session
    @State private var selecedTab = 0
    var body: some View {
        if session.currentStaff == nil {
            SignInView()
        } else {
            TabView(selection: $selecedTab) {
                NavigationStack {
                    FeedView()
                }
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                } .tag(0)
                
                NavigationStack {
                    RosterView()
                }
                .tabItem {
                    Label("Roster", systemImage: "person.3")
                } .tag(1)
            }
            .onChange(of: selecedTab) {
                session.recordActivity()
            }
        }
    }
}
