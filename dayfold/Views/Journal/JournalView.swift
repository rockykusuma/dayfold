import SwiftUI
import SwiftData
import DayfoldCore

/// The Journal tab: Insights on top, filter chips, then entry cards newest first, grouped by month.
struct JournalView: View {
    enum Filter: String, CaseIterable, Identifiable {
        case all = "All", bookmarked = "Bookmarked", photos = "With photos"
        var id: String { rawValue }
    }

    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @Query private var tasks: [Entry]
    @State private var filter = Filter.all
    @State private var day: Date?
    @State private var editing: JournalEntry?
    @State private var creating = false
    @State private var deleting: JournalEntry?
    @State private var bookmarkTaps = 0
    #if DEBUG
    @State private var showWeek = CommandLine.arguments.contains("-week")
    #else
    @State private var showWeek = false
    #endif

    private let calendar = Calendar.current
    private var motion: Animation? { reduceMotion ? nil : .snappy }

    private var shown: [JournalEntry] {
        entries.filter { e in
            switch filter {
            case .all: true
            case .bookmarked: e.isBookmarked
            case .photos: e.hasPhotos
            }
        }
        .filter { e in day.map { calendar.isDate(e.date, inSameDayAs: $0) } ?? true }
    }

    /// Consecutive runs of the (already newest-first) feed that share a month.
    private var months: [(month: Date, entries: [JournalEntry])] {
        var groups: [(month: Date, entries: [JournalEntry])] = []
        for e in shown {
            let m = calendar.dateInterval(of: .month, for: e.date)?.start ?? e.date
            if groups.last?.month == m { groups[groups.count - 1].entries.append(e) } else { groups.append((m, [e])) }
        }
        return groups
    }

    var body: some View {
        ScrollViewReader { proxy in
            List {
                InsightsCard(entries: entries, tasks: tasks,
                             onSelectDay: { d in
                                 // Bring the filtered feed into view; on small phones the calendar fills the screen.
                                 withAnimation(motion) { day = d; proxy.scrollTo("chips", anchor: .top) }
                             },
                             onWeek: { showWeek = true })
                    .listRow()

                if entries.isEmpty {
                    emptyState.listRow()
                } else {
                    chips.listRow(insets: EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .id("chips")
                    let months = months
                    if months.isEmpty {
                        Text("Nothing matches this filter.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .listRow()
                    }
                    ForEach(months, id: \.month) { group in
                        Section {
                            ForEach(group.entries) { card($0) }
                        } header: {
                            Text(group.month, format: .dateTime.month(.wide).year())
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        // A cover, not a view swap: the feed and any open editor sheet stay mounted, so relocking keeps a draft.
        .journalLockCover()
        .navigationTitle("Journal")
        #if os(iOS)
        .toolbarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {   // the list insets its content, so the last card clears it
            if !JournalLock.shared.isHidden { plusButton }
        }
        #else
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { creating = true } label: { Label("New Entry", systemImage: "square.and.pencil") }
                    .keyboardShortcut("n", modifiers: [.command, .option])
                    .help("New Entry")
                    .disabled(JournalLock.shared.isHidden)
            }
        }
        #endif
        .sensoryFeedback(.selection, trigger: bookmarkTaps)
        .sheet(item: $editing) { JournalEditor(entry: $0) }
        .sheet(isPresented: $creating) { JournalEditor(entry: nil) }
        .navigationDestination(isPresented: $showWeek) { WeekView() }
        #if DEBUG
        // `-edit <title or text prefix>` opens that journal entry (screenshots can't tap).
        .task {
            let args = CommandLine.arguments
            guard let i = args.firstIndex(of: "-edit"), i + 1 < args.count else { return }
            editing = entries.first { $0.title.hasPrefix(args[i + 1]) || $0.text.hasPrefix(args[i + 1]) }
        }
        #endif
        .confirmationDialog("Delete this entry?", isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                            titleVisibility: .visible, presenting: deleting) { entry in
            Button("Delete", role: .destructive) { withAnimation(motion) { context.delete(entry) } }
        }
    }

    // MARK: Pieces

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // First, so it is on screen when a calendar day is tapped.
                if let day {
                    chip(selected: true) { withAnimation(motion) { self.day = nil } } label: {
                        HStack(spacing: 6) {
                            Text("Showing \(day.formatted(.dateTime.weekday(.abbreviated).day()))")
                            Image(systemName: "xmark").font(.caption.weight(.semibold)).accessibilityHidden(true)
                        }
                    }
                    .accessibilityHint("Shows every day again")
                    .transition(.opacity)
                }
                ForEach(Filter.allCases) { f in
                    chip(selected: filter == f) { withAnimation(motion) { filter = f } } label: { Text(f.rawValue) }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip<L: View>(selected: Bool, action: @escaping () -> Void, @ViewBuilder label: () -> L) -> some View {
        Button(action: action) {
            label()
                .font(.subheadline)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .background(selected ? AnyShapeStyle(Color.accentColor.opacity(0.15)) : AnyShapeStyle(Color.card), in: Capsule())
                .overlay(Capsule().strokeBorder(selected ? AnyShapeStyle(.tint) : AnyShapeStyle(.separator), lineWidth: selected ? 1 : 0.5))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func card(_ entry: JournalEntry) -> some View {
        Button { editing = entry } label: { JournalCard(entry: entry) }
            .buttonStyle(.plain)
            .listRow(insets: EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
            .swipeActions(edge: .leading) {
                Button { toggleBookmark(entry) } label: {
                    entry.isBookmarked ? Label("Remove bookmark", systemImage: "bookmark.slash")
                                       : Label("Bookmark", systemImage: "bookmark")
                }
                .tint(.accentColor)
            }
            .swipeActions(edge: .trailing) {
                // Not `role: .destructive`: the row stays until the confirmation says Delete.
                Button { deleting = entry } label: { Label("Delete", systemImage: "trash") }
                    .tint(.red)
            }
            .contextMenu {
                Button(entry.isBookmarked ? "Remove bookmark" : "Bookmark",
                       systemImage: entry.isBookmarked ? "bookmark.slash" : "bookmark") { toggleBookmark(entry) }
                Divider()
                Button("Delete", systemImage: "trash", role: .destructive) { deleting = entry }
            }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text("Your journal is empty")
                .font(.system(.title3, design: .serif, weight: .semibold))
            Text("Tap + to write about your day.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    #if os(iOS)
    private var plusButton: some View {
        Button { creating = true } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.paper)
                .frame(width: 56, height: 56)
                .background(Circle().fill(.tint))
                .shadow(color: .black.opacity(0.15), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .keyboardShortcut("n", modifiers: [.command, .option])
        .accessibilityLabel("New Entry")
        .padding(.bottom, 8)
    }
    #endif

    // MARK: Actions

    private func toggleBookmark(_ entry: JournalEntry) {
        withAnimation(motion) {
            entry.isBookmarked.toggle()
            entry.updatedAt = Date()   // dedupe keeps the newest copy
        }
        bookmarkTaps += 1
    }
}

private extension View {
    /// Clear, separator-free row; a readable column on wide windows.
    func listRow(insets: EdgeInsets = EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) -> some View {
        frame(maxWidth: 640).frame(maxWidth: .infinity)
            .listRowInsets(insets)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}
