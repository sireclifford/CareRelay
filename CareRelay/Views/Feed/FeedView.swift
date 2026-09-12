import SwiftUI
import SwiftData

struct FeedView: View {
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]

    @State private var isPresentingCompose = false

    private var openAlerts: [Entry] {
        entries
            .filter { $0.kind == .alert && $0.status == .open }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var rest: [Entry] {
        entries.filter { !($0.kind == .alert && $0.status == .open) }
    }

    var body: some View {
        List {
            if !openAlerts.isEmpty {
                Section("Needs Attention") {
                    ForEach(openAlerts) { entry in
                        EntryRow(entry: entry)
                    }
                }
            }
            Section {
                ForEach(rest) { entry in
                    EntryRow(entry: entry)
                }
            }
        }
        .navigationTitle("Feed")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingCompose = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingCompose) {
            ComposeEntryView()
        }
    }
}
