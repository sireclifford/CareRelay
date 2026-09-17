import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @Environment(Session.self) private var session
    
    var body: some View {
        if session.currentStaff == nil {
            SignInView()
        } else {
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
}
