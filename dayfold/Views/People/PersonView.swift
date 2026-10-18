import SwiftUI
import SwiftData
import DayfoldCore

/// One person: what R owes them, what R is waiting on, and 1:1 notes. Capture is pre-linked.
struct PersonView: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var pendingRemoval: (() -> Void)?
    @State private var link: PersonLink = .from
    @State private var editing = false
    @FocusState private var captureFocused: Bool

    private let today = Calendar.current.startOfDay(for: Date())
    private var first: String { person.name.split(separator: " ").first.map(String.init) ?? person.name }
    private var isEmpty: Bool { person.owed.isEmpty && person.waiting.isEmpty && person.notes.isEmpty }

    var body: some View {
        if person.isDeleted || person.modelContext == nil {
            Color.paper
        } else {
            content
        }
    }

    private var content: some View {
        List {
            header
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            section("You owe \(first)", person.owed)
            section("Waiting on \(first)", person.waiting)
            section("1:1 notes", person.notes)
            if isEmpty {
                Text("Nothing yet. Capture below — choose I owe, Waiting or 1:1 note.")
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Picker("Capture as", selection: $link) {
                    Text("I owe").tag(PersonLink.from)
                    Text("Waiting").tag(PersonLink.to)
                    Text("1:1 note").tag(PersonLink.about)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.horizontal, 12)
                .padding(.top, 8)
                CaptureBar(filter: .all, day: Date(), focus: $captureFocused, linkedTo: (person, link))
            }
            .background(.bar)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) { Button("Edit") { editing = true } }
        }
        #if os(iOS)
        .toolbarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $editing) { PersonEditor(person: person) { change in
            pendingRemoval = change
            editing = false
            dismiss()
        }
        }
        .onDisappear {
            if let change = pendingRemoval {
                pendingRemoval = nil
                withAnimation { change() }
                try? context.save()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text([person.team, person.role.title].compactMap { $0 }.joined(separator: " · "))
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.tint)
            Text(person.name)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var summary: String {
        var parts = ["\(person.owed.count) you owe", "\(person.waiting.count) waiting"]
        if let last = person.notes.first {
            parts.append("last note \(last.createdAt.formatted(.relative(presentation: .named)))")
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private func section(_ title: String, _ entries: [Entry]) -> some View {
        if !entries.isEmpty {
            Section {
                ForEach(entries) { entry in
                    EntryRow(entry: entry, day: today) { toggle(entry) }
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func toggle(_ entry: Entry) {
        withAnimation(.snappy) {
            if entry.status.isActive { Review.apply(.done, to: entry) } else { Review.reopen(entry) }
        }
    }
}
