import SwiftUI
import SwiftData

struct SignInView: View {
    @Environment(Session.self) private var session
    @Query(sort: \Staff.name) private var allStaff: [Staff]
    
    var body: some View {
        NavigationStack {
            List(allStaff) { staff in
                Button {
                    session.currentStaff = staff
                } label: {
                    Text(staff.name)
                }
            }
            .navigationTitle("Who's working?")
        }
    }
}
