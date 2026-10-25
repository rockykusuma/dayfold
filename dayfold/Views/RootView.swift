import SwiftUI
import SwiftData
import DayfoldCore

/// iPhone: Today, People, Search, Journal and Notes tabs. Mac: sidebar with Today, Journal, Notes, People, teams, and All waiting.
struct RootView: View {
    #if os(macOS)
    enum SidebarItem: Hashable { case today, journal, notes, people, team(String), waiting, search, tag(String) }

    @Query(sort: \Person.name) private var people: [Person]
    @Query(sort: \Entry.createdAt) private var entries: [Entry]
    #if DEBUG
    @State private var selection: SidebarItem? = CommandLine.arguments.contains("-search") ? .search
        : CommandLine.arguments.contains("-notes") ? .notes
        : CommandLine.arguments.contains("-journal") || CommandLine.arguments.contains("-week") ? .journal : .today
    #else
    @State private var selection: SidebarItem? = .today
    #endif
    private var teams: [String] { Array(Set(people.compactMap(\.team))).sorted() }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("Today", systemImage: "calendar").tag(SidebarItem.today)
                Label("Journal", systemImage: "book.closed").tag(SidebarItem.journal)
                Label("Notes", systemImage: "books.vertical").tag(SidebarItem.notes)
                Label("People", systemImage: "person.2").tag(SidebarItem.people)
                Label("Search", systemImage: "magnifyingglass").tag(SidebarItem.search)
                let tags = Tags.all(entries)
                if !tags.isEmpty {
                    Section("Tags") {
                        ForEach(tags.prefix(8)) { t in
                            Label("#\(t.tag)", systemImage: "number").badge(t.count).tag(SidebarItem.tag(t.tag))
                        }
                    }
                }
                if !teams.isEmpty {
                    Section("Teams") {
                        ForEach(teams, id: \.self) { team in
                            Label(team, systemImage: "person.3").tag(SidebarItem.team(team))
                        }
                    }
                }
                Section("Waiting") {
                    Label("All waiting", systemImage: "arrow.forward.circle").tag(SidebarItem.waiting)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch selection ?? .today {
            case .today: DayPageView()
            case .journal: NavigationStack { JournalView() }
            case .notes: NotesView()
            case .people: NavigationStack { PeopleListView() }
            case .team(let team): NavigationStack { PeopleListView(team: team) }.id(team)
            case .waiting: NavigationStack { AllWaitingView() }
            case .search, .tag: NavigationStack { SearchView() }
            }
        }
        // Review sheet lives in DayPageView, so bring Today forward when Review is requested.
        .onChange(of: ReviewReminder.shared.showReview) { _, show in
            if show { selection = .today }
        }
        .onChange(of: selection) { _, item in
            if case .tag(let t) = item { SearchRouter.shared.query = "#\(t)" }
        }
        .onChange(of: SearchRouter.shared.shown) { selection = .search }
        .onChange(of: CaptureRouter.shared.requests) { selection = .today }
        #if DEBUG
        .task { applySearchFlag() }
        #endif
    }
    #else
    #if DEBUG
    @State private var tab = CommandLine.arguments.contains("-search") ? 2
        : CommandLine.arguments.contains("-journal") || CommandLine.arguments.contains("-week") ? 3
        : CommandLine.arguments.contains("-notes") ? 4
        : CommandLine.arguments.contains("-people") || CommandLine.arguments.contains("-person") ? 1 : 0
    @Environment(\.modelContext) private var context
    #else
    @State private var tab = 0
    #endif
    @State private var peoplePath: [Person] = []

    var body: some View {
        TabView(selection: $tab) {
            DayPageView()
                .tabItem { Label("Today", systemImage: "calendar") }
                .tag(0)
            NavigationStack(path: $peoplePath) { PeopleListView() }
                .tabItem { Label("People", systemImage: "person.2") }
                .tag(1)
            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(2)
            NavigationStack { JournalView() }
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(3)
            NotesView()
                .tabItem { Label("Notes", systemImage: "books.vertical") }
                .tag(4)
        }
        #if DEBUG
        .task { applySearchFlag() }
        // `-person <Name>` opens that person's page (screenshots can't tap).
        .task {
            let args = CommandLine.arguments
            guard let i = args.firstIndex(of: "-person"), i + 1 < args.count,
                  let all = try? context.fetch(FetchDescriptor<Person>()),
                  let k = PeopleDirectory.match(args[i + 1], in: all.map(\.name)) else { return }
            peoplePath = [all[k]]
        }
        #endif
        // Review sheet lives in DayPageView, so bring Today forward when Review is requested.
        .onChange(of: ReviewReminder.shared.showReview) { _, show in
            if show { tab = 0 }
        }
        .onChange(of: SearchRouter.shared.shown) { tab = 2 }
        .onChange(of: CaptureRouter.shared.requests) { tab = 0 }
    }
    #endif
}

#if DEBUG
/// `-search [query]` pre-fills the Search query (screenshots can't type).
private func applySearchFlag() {
    let args = CommandLine.arguments
    if let i = args.firstIndex(of: "-search"), i + 1 < args.count, !args[i + 1].hasPrefix("-") {
        SearchRouter.shared.query = args[i + 1]
    }
}
#endif
