import SwiftUI
import SwiftData
import DayfoldCore

/// One week looking back: Done by person, Stuck, Waiting on, journal entries. ‹ › browse weeks.
/// Rules live in `WeekReview`; this view only lays them out.
struct WeekView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \Entry.createdAt) private var entries: [Entry]
    @Query private var journal: [JournalEntry]
    /// Weeks back from now (0 = this week).
    @State private var weekOffset = 0
    @State private var editing: Entry?
    @State private var openedPerson: Person?
    @State private var openedJournal: JournalEntry?
    @State private var writingToday = false
    @State private var copied = false

    private let calendar = Calendar.current
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var anchor: Date { calendar.date(byAdding: .day, value: 7 * weekOffset, to: Date()) ?? Date() }
    private var motion: Animation? { reduceMotion ? nil : .snappy }

    var body: some View {
        let review = WeekReview(entries: entries, journal: journal, containing: anchor, today: Date())
        let title = "Week of \(review.interval.start.formatted(.dateTime.day().month(.abbreviated)))"
        List {
            header(review, title: title)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if review.isEmpty {
                emptyState
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            if !review.done.isEmpty {
                Section { groups(review.done, lookBack: true) } header: { sectionHeader("Done") }
            }
            if !review.stuck.isEmpty {
                Section {
                    ForEach(review.stuck) { stuckRow($0) }
                } header: {
                    VStack(alignment: .leading, spacing: 2) {
                        sectionHeader("Stuck")
                        Text("Open 3+ days. Finish, push or let go.")   // headers are already dimmed
                            .font(.caption)
                    }
                }
            }
            if !review.waiting.isEmpty {
                Section { groups(review.waiting) } header: { sectionHeader("Waiting on") }
            }
            notesSection(review)
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 28) // person sub-headers; entry rows keep their 44pt marks
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        #if os(macOS)
        .navigationTitle(title)
        #else
        .toolbarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            if !(review.done.isEmpty && review.stuck.isEmpty && review.waiting.isEmpty) {
                let text = review.summaryText(title: title)
                ToolbarItemGroup(placement: .primaryAction) {
                    ShareLink(item: text, subject: Text(title)) {
                        Label("Share update", systemImage: "square.and.arrow.up")
                    }
                    Button(copied ? "Copied" : "Copy") { copy(text) }
                        .help("Copy the week as text")
                }
            }
        }
        .sensoryFeedback(.success, trigger: copied) { _, new in new }
        .task(id: copied) {
            guard copied else { return }
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(motion) { copied = false }
        }
        .sheet(item: $editing) { EntryEditor(entry: $0) }
        .sheet(item: $openedJournal) { JournalEditor(entry: $0) }
        .sheet(isPresented: $writingToday) { JournalEditor(entry: nil) }
        .navigationDestination(item: $openedPerson) { PersonView(person: $0) }
    }

    // MARK: Header

    private func header(_ review: WeekReview, title: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(.title, design: .serif, weight: .semibold))
                    .contentTransition(.numericText())
                Spacer(minLength: 8)
                weekButton(-1, symbol: "chevron.left", label: "Previous week", key: .leftArrow)
                weekButton(1, symbol: "chevron.right", label: "Next week", key: .rightArrow)
                    .disabled(review.isCurrent)
            }
            HStack {
                if let counts = counts(review) {
                    Text(counts)
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                if !review.isCurrent {
                    Button("This week") { withAnimation(motion) { weekOffset = 0 } }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                        .keyboardShortcut("t", modifiers: .command)
                }
            }
            .frame(minHeight: 28)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1) // display text; rows below scale fully
    }

    /// "12 done · 2 dropped", zero parts omitted; nil when both are zero.
    private func counts(_ review: WeekReview) -> String? {
        let done = review.done.reduce(0) { $0 + $1.entries.count }
        let parts = [done > 0 ? "\(done) done" : nil, review.droppedCount > 0 ? "\(review.droppedCount) dropped" : nil]
            .compactMap { $0 }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private func weekButton(_ direction: Int, symbol: String, label: String, key: KeyEquivalent) -> some View {
        Button {
            withAnimation(motion) { weekOffset += direction }
        } label: {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .keyboardShortcut(key, modifiers: .command)
        .accessibilityLabel(label)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(.headline, design: .serif))
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("A quiet week")
                .font(.system(.title3, design: .serif, weight: .semibold))
            Text("Nothing was closed this week.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: Rows

    /// Per-person sub-header, then that person's rows.
    @ViewBuilder private func groups(_ groups: [PersonGroup], lookBack: Bool = false) -> some View {
        ForEach(groups) { group in
            Group {
                if let person = group.person {
                    Button { openedPerson = person } label: { groupLabel(person.name) }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens \(person.name)")
                } else {
                    groupLabel("Everything else")
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 0, trailing: 20))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .accessibilityAddTraits(.isHeader)
            ForEach(group.entries) { row($0, lookBack: lookBack) }
        }
    }

    private func groupLabel(_ name: String) -> some View {
        Text(name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .contentShape(Rectangle())
    }

    private func row(_ entry: Entry, lookBack: Bool = false) -> some View {
        EntryRow(entry: entry, day: today, lookBack: lookBack, onToggle: { toggle(entry) }, onPerson: { openedPerson = $0 })
            .contentShape(Rectangle())
            .onTapGesture { editing = entry }
            .accessibilityAction(named: "Edit") { editing = entry }
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 20))
            .listRowBackground(Color.clear)
    }

    /// Neutral colours: Stuck is an invitation to decide, not a warning.
    private func stuckRow(_ entry: Entry) -> some View {
        row(entry)
            .swipeActions(edge: .leading) {
                Button { apply(.done, to: entry) } label: { Label("Done", systemImage: "checkmark") }
                    .tint(.accentColor)
            }
            .swipeActions(edge: .trailing) {
                Button { apply(.drop, to: entry) } label: { Label("Drop", systemImage: "xmark") }
                    .tint(.gray)
                Button { apply(.push(to: tomorrow), to: entry) } label: {
                    Label("Push to tomorrow", systemImage: "arrow.turn.down.right")
                }
                .tint(.accentColor)
            }
            .contextMenu {
                Button("Done", systemImage: "checkmark") { apply(.done, to: entry) }
                Button("Push to tomorrow", systemImage: "arrow.turn.down.right") { apply(.push(to: tomorrow), to: entry) }
                Button("Drop", systemImage: "xmark") { apply(.drop, to: entry) }
            }
    }

    @ViewBuilder private func notesSection(_ review: WeekReview) -> some View {
        let missingToday = review.isCurrent && !review.entries.contains { calendar.isDate($0.date, inSameDayAs: today) }
        if !review.entries.isEmpty || missingToday {
            Section {
                ForEach(review.entries) { entry in
                    Button { openedJournal = entry } label: {
                        (Text(entry.date, format: .dateTime.weekday(.abbreviated).day()).foregroundStyle(.secondary)
                            + Text(" · ").foregroundStyle(.secondary)
                            + Text(entry.preview).font(.system(.body, design: .serif)))
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                    .listRowBackground(Color.clear)
                }
                if missingToday {
                    Button { writingToday = true } label: {
                        Label("Write about today", systemImage: "plus")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.tint)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowBackground(Color.clear)
                }
            } header: {
                sectionHeader("Notes")
            }
        }
    }

    // MARK: Actions

    private var tomorrow: Date { calendar.date(byAdding: .day, value: 1, to: today) ?? today }

    private func apply(_ action: ReviewAction, to entry: Entry) {
        withAnimation(motion) { Review.apply(action, to: entry, context: context) }
    }

    /// Done ↔ open, as on Search: a not-yet-shown occurrence can't be ticked early.
    private func toggle(_ entry: Entry) {
        if entry.status.isActive && entry.showOn > today { return }
        withAnimation(motion) {
            if entry.status.isActive { Review.apply(.done, to: entry, context: context) } else { Review.reopen(entry) }
        }
    }

    private func copy(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
        withAnimation(motion) { copied = true }
    }
}
