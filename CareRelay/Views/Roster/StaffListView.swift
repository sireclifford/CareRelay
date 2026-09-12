import SwiftUI
import SwiftData

struct StaffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Staff.name) private var staffMembers: [Staff]
    @State private var isPresentingAdd = false

    var body: some View {
        List {
            ForEach(staffMembers) { staff in
                VStack(alignment: .leading) {
                    Text(staff.name)
                    Text(staff.role.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete(perform: deleteStaff)
        }
        .navigationTitle("Staff")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            AddStaffView()
        }
    }

    private func deleteStaff(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(staffMembers[index])
        }
    }
}
