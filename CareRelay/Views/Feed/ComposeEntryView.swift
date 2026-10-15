import SwiftUI
import SwiftData

struct ComposeEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(Session.self) private var session

    @Query(sort: \Unit.name) private var units: [Unit]
    @Query(sort: \Resident.name) private var residents: [Resident]
    @Query(sort: \QuickPhrase.createdAt) private var quickPhrases: [QuickPhrase]

    @State private var kind: EntryKind = .notice
    @State private var selectedUnit: Unit?
    @State private var selectedResident: Resident?
    @State private var category: EntryCategory = .other
    @State private var content: String = ""
    @State private var isAddingPhrase = false
    @State private var newPhraseText = ""

    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var phrasesForCategory: [QuickPhrase] {
        quickPhrases.filter { $0.category == category }
    }

    private var canManagePhrases: Bool {
        session.currentStaff?.role.canManageRoster ?? false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Kind", selection: $kind) {
                        Text("Notice").tag(EntryKind.notice)
                        Text("Alert").tag(EntryKind.alert)
                    }
                    .pickerStyle(.segmented)

                    Picker("Category", selection: $category) {
                        ForEach(EntryCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                } header: {
                    Text("Type")
                } footer: {
                    Text(kind == .alert
                         ? "Alerts are pinned at the top of the feed and stay open until resolved."
                         : "Notices are informational and don't need to be resolved.")
                }

                Section {
                    Picker("Unit", selection: $selectedUnit) {
                        Text("Facility-wide").tag(Unit?.none)
                        ForEach(units) { unit in
                            Text(unit.name).tag(Unit?.some(unit))
                        }
                    }

                    Picker("Resident", selection: $selectedResident) {
                        Text("None").tag(Resident?.none)
                        ForEach(residents) { resident in
                            Text(resident.name).tag(Resident?.some(resident))
                        }
                    }
                } header: {
                    Text("Where")
                } footer: {
                    Text("Leave Unit as Facility-wide for entries that affect everyone. Resident is optional.")
                }

                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.small) {
                            Button {
                                isAddingPhrase = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add")
                                }
                                .font(.footnote)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.secondary.opacity(0.12))
                                .foregroundStyle(.secondary)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            ForEach(phrasesForCategory) { phrase in
                                HStack(spacing: 4) {
                                    Button {
                                        appendPhrase(phrase.text)
                                    } label: {
                                        Text(phrase.text)
                                    }
                                    .buttonStyle(.plain)

                                    if canManagePhrases {
                                        Button {
                                            modelContext.delete(phrase)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .font(.footnote)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColor.accent.opacity(0.12))
                                .foregroundStyle(AppColor.accent)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)

                    TextField("What's going on?", text: $content, axis: .vertical)
                        .lineLimit(4...8)
                } header: {
                    Text("Details")
                } footer: {
                    Text("Posted as \(session.currentStaff?.name ?? "the signed-in staff member").")
                }
            }
            .navigationTitle("New Entry")
            .dismissableKeyboard()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(trimmedContent.isEmpty || session.currentStaff == nil)
                }
            }
            .alert("New Phrase", isPresented: $isAddingPhrase) {
                TextField("Phrase", text: $newPhraseText)
                Button("Add") { addPhrase() }
                Button("Cancel", role: .cancel) {
                    newPhraseText = ""
                }
            }
        }
    }

    private func appendPhrase(_ phrase: String) {
        if content.isEmpty {
            content = phrase
        } else if content.hasSuffix(" ") || content.hasSuffix("\n") {
            content += phrase
        } else {
            content += " " + phrase
        }
    }

    private func addPhrase() {
        let trimmed = newPhraseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            newPhraseText = ""
            return
        }
        let phrase = QuickPhrase(text: trimmed, category: category)
        modelContext.insert(phrase)
        newPhraseText = ""
    }

    private func save() {
        let entry = Entry(
            kind: kind,
            unit: selectedUnit,
            resident: selectedResident,
            category: category,
            content: trimmedContent,
            author: session.currentStaff
        )
        modelContext.insert(entry)
        dismiss()
    }
}
