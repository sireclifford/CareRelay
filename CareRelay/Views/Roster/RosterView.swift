import SwiftUI

struct RosterView: View {
    @Environment(Session.self) private var session
    
    var body: some View {
        List {
            Section {
                if let staff = session.currentStaff {
                    HStack {
                        Text("Signed in as \(staff.name)")
                        Spacer()
                        Button("Switch") {
                            session.currentStaff = nil
                        }
                    }
                }
            }
            
            NavigationLink("Units") {
                UnitsListView()
            }
            NavigationLink("Staff") {
                StaffListView()
            }
            NavigationLink("Residents") {
                ResidentsListView()
            }
        }
        .navigationTitle("Roster")
    }
}
