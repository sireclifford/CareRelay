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
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    "No Entries Yet",
                    systemImage: "tray",
                    description: Text("Tap the + button to log the first entry for your shift.")
                )
            } else {
                List {
                    if !openAlerts.isEmpty {
                        Section {
                            ForEach(openAlerts) { entry in
                                NavigationLink {
                                    EntryDetailView(entry: entry)
                                } label: {
                                    EntryRow(entry: entry)
                                }
                            }
                        } header: {
                            Label("Needs Attention", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColor.alertOpen)
                        }
                    }

                    if !rest.isEmpty {
                        Section("Recent Activity") {
                            ForEach(rest) { entry in
                                NavigationLink {
                                    EntryDetailView(entry: entry)
                                } label: {
                                    EntryRow(entry: entry)
                                }
                            }
                        }
                    }
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
