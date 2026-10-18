import SwiftUI
import SwiftData
import DayfoldCore

/// iPhone: Today and People tabs. Mac: sidebar with Today, People, teams, and All waiting.
struct RootView: View {
    #if os(macOS)
    enum SidebarItem: Hashable { case today, people, team(String), waiting }

    @Query(sort: \Person.name) private var people: [Person]
    @State private var selection: SidebarItem? = .today
    private var teams: [String] { Array(Set(people.compactMap(\.team))).sorted() }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("Today", systemImage: "calendar").tag(SidebarItem.today)
                Label("People", systemImage: "person.2").tag(SidebarItem.people)
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
            case .people: NavigationStack { PeopleListView() }
            case .team(let team): NavigationStack { PeopleListView(team: team) }.id(team)
            case .waiting: NavigationStack { AllWaitingView() }
            }
        }
        // Review sheet lives in DayPageView, so bring Today forward when Review is requested.
        .onChange(of: ReviewReminder.shared.showReview) { _, show in
            if show { selection = .today }
        }
    }
    #else
    #if DEBUG
    @State private var tab = CommandLine.arguments.contains("-people") || CommandLine.arguments.contains("-person") ? 1 : 0
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
        }
        #if DEBUG
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
    }
    #endif
}
