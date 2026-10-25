import SwiftUI
import SwiftData
import DayfoldCore

/// Find across everything: browse chips and tags when the query is empty, grouped results otherwise.
struct SearchView: View {
    @Query(sort: \Entry.createdAt) private var entries: [Entry]
    @Query(sort: \Person.name) private var people: [Person]
    @Query(sort: \JournalEntry.date, order: .reverse) private var journal: [JournalEntry]
    @Bindable private var router = SearchRouter.shared
    @Environment(\.modelContext) private var context
    @State private var editing: Entry?
    @State private var journalEditing: JournalEntry?
    @State private var openedPerson: Person?

    private let today = Calendar.current.startOfDay(for: Date())
    private let filters = [("Open", "is:open"), ("Priority", "is:priority"),
                           ("Repeating", "is:repeating"), ("Waiting", "is:waiting")]

    private var query: String { router.query.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        // ponytail: recomputed per keystroke (see SearchTests.largeStore). Debounce if stores grow large.
        let results = query.isEmpty ? [] : Search.results(entries, query: router.query)
        // Locked: no Journal section (its editor sheet hangs off the List, so it stays up).
        let journalMatches = query.isEmpty || JournalLock.shared.isHidden ? [] : Search.journal(journal, query: router.query)
        List {
            if query.isEmpty {
                browse
            } else if results.isEmpty && journalMatches.isEmpty {
                ContentUnavailableView {
                    Label { Text("Nothing matches").font(.system(.title2, design: .serif, weight: .semibold)) }
                          icon: { Image(systemName: "magnifyingglass") }
                } description: {
                    Text("“\(query)”")
                }
                    .listRowBackground(Color.clear)
            } else {
                if !journalMatches.isEmpty {
                    Section {
                        ForEach(journalMatches) { e in
                            JournalRow(entry: e, showDate: true) { journalEditing = e }
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        Text("Journal").font(.system(.headline, design: .serif))
                    }
                }
                ForEach(Search.dayGroups(results)) { group in
                    Section {
                        ForEach(group.entries) { entry in
                            EntryRow(entry: entry, day: today, onToggle: { toggle(entry) },
                                     onPerson: { openedPerson = $0 })
                                .contentShape(Rectangle())
                                .onTapGesture { editing = entry }
                                .accessibilityAction(named: "Edit") { editing = entry }
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        Text(group.day, format: .dateTime.weekday(.wide).day().month(.wide))
                            .font(.system(.headline, design: .serif))
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .navigationTitle("Search")
        .searchable(text: $router.query, prompt: "Search everything")
        .searchSuggestions { suggestions }
        .sheet(item: $editing) { EntryEditor(entry: $0) }
        .sheet(item: $journalEditing) { JournalEditor(entry: $0) }
        .navigationDestination(item: $openedPerson) { PersonView(person: $0) }
        // A tag tapped on a pushed person page should show its results, not stay on the page.
        .onChange(of: router.shown) { openedPerson = nil }
    }

    @ViewBuilder private var browse: some View {
        let tags = Tags.all(entries)
        FlowLayout {
            ForEach(filters, id: \.1) { name, q in chip(name) { router.query = q } }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        if !tags.isEmpty {
            Text("Tags")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            FlowLayout {
                ForEach(tags) { t in chip("#\(t.tag)  \(t.count)") { router.query = "#\(t.tag)" } }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder private var suggestions: some View {
        if let token = Search.completionToken(in: router.query) {
            if token.sigil == "#" {
                let key = Tags.key(token.partial)
                ForEach(Tags.all(entries).filter { Tags.key($0.tag).hasPrefix(key) }.prefix(5)) { t in
                    Button("#\(t.tag)") { insert("#\(t.tag)") }
                }
            } else {
                let names = people.map(\.name)
                ForEach(PeopleDirectory.completions(for: token.partial, in: names), id: \.self) { i in
                    Button("@\(names[i])") { insert("@" + names[i].replacingOccurrences(of: " ", with: "_")) }
                }
            }
        }
    }

    private func insert(_ token: String) {
        router.query = Search.replacingTrailingToken(in: router.query, with: token)
    }

    private func chip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .background(Color.card, in: Capsule())
                .overlay(Capsule().strokeBorder(.separator, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func toggle(_ entry: Entry) {
        // Next week's occurrence can't be ticked early (its row's mark is disabled too).
        if entry.status.isActive && entry.showOn > today { return }
        withAnimation(.snappy) {
            if entry.status.isActive { Review.apply(.done, to: entry, context: context) } else { Review.reopen(entry) }
        }
        try? context.save()
    }
}

/// Wraps chips onto new lines.
private struct FlowLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let spots = arrange(subviews, width: bounds.width).spots
        for (view, p) in zip(subviews, spots) {
            view.place(at: CGPoint(x: bounds.minX + p.x, y: bounds.minY + p.y), proposal: .unspecified)
        }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> (spots: [CGPoint], size: CGSize) {
        var spots: [CGPoint] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0, maxX: CGFloat = 0
        for s in subviews {
            let size = s.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width { x = 0; y += rowH + 8; rowH = 0 }
            spots.append(CGPoint(x: x, y: y))
            x += size.width + 8
            rowH = max(rowH, size.height)
            maxX = max(maxX, x - 8)
        }
        return (spots, CGSize(width: maxX, height: y + rowH))
    }
}
