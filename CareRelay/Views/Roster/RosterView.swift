import SwiftUI

struct RosterView: View {
    var body: some View {
        List {
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
