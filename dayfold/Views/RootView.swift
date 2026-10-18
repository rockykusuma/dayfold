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
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            DayPageView()
                .tabItem { Label("Today", systemImage: "calendar") }
                .tag(0)
            NavigationStack { PeopleListView() }
                .tabItem { Label("People", systemImage: "person.2") }
                .tag(1)
        }
        // Review sheet lives in DayPageView, so bring Today forward when Review is requested.
        .onChange(of: ReviewReminder.shared.showReview) { _, show in
            if show { tab = 0 }
        }
    }
    #endif
}
