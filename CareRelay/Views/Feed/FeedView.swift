import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(Session.self) private var session
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @Query(sort: \Unit.name) private var units: [Unit]

    @State private var isPresentingCompose = false
    @State private var selectedUnit: Unit?

    private var filteredEntries: [Entry] {
        guard let selectedUnit else { return entries }
        return entries.filter { $0.unit == nil || $0.unit?.id == selectedUnit.id }
    }

    private var openAlerts: [Entry] {
        filteredEntries
            .filter { $0.kind == .alert && $0.status == .open }
            .sorted { $0.createdAt < $1.createdAt }
    }

    private var rest: [Entry] {
        filteredEntries.filter { !($0.kind == .alert && $0.status == .open) }
    }

    private var unreadForMe: [Entry] {
        rest.filter { !$0.isRead(by: session.currentStaff) }
    }

    private var readByMe: [Entry] {
        rest.filter { $0.isRead(by: session.currentStaff) }
    }

    private var filterLabel: String {
        selectedUnit?.name ?? "All Units"
    }

    var body: some View {
        Group {
            if entries.isEmpty {
                ContentUnavailableView(
                    "No Entries Yet",
                    systemImage: "tray",
                    description: Text("Tap the + button to log the first entry for your shift.")
                )
            } else if filteredEntries.isEmpty {
                ContentUnavailableView(
                    "No Entries for \(filterLabel)",
                    systemImage: "tray",
                    description: Text("Try a different unit, or switch back to All Units.")
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

                    if !unreadForMe.isEmpty {
                        Section {
                            ForEach(unreadForMe) { entry in
                                NavigationLink {
                                    EntryDetailView(entry: entry)
                                } label: {
                                    EntryRow(entry: entry)
                                }
                            }
                        } header: {
                            Label("New to You", systemImage: "circle.fill")
                                .foregroundStyle(AppColor.accent)
                        }
                    }

                    if !readByMe.isEmpty {
                        Section("Recent Activity") {
                            ForEach(readByMe) { entry in
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
            ToolbarItemGroup(placement: .primaryAction) {
                Menu {
                    Button {
                        selectedUnit = nil
                    } label: {
                        if selectedUnit == nil {
                            Label("All Units", systemImage: "checkmark")
                        } else {
                            Text("All Units")
                        }
                    }

                    ForEach(units) { unit in
                        Button {
                            selectedUnit = unit
                        } label: {
                            if selectedUnit?.id == unit.id {
                                Label(unit.name, systemImage: "checkmark")
                            } else {
                                Text(unit.name)
                            }
                        }
                    }
                } label: {
                    Image(systemName: selectedUnit == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }

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
