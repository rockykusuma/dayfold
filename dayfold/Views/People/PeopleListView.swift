import SwiftUI
import SwiftData
import DayfoldCore

/// Everyone R works with, grouped by role. Mac sidebar team rows pass `team`.
struct PeopleListView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
    var team: String? = nil
    @State private var teamFilter: String?

    private let today = Calendar.current.startOfDay(for: Date())
    private var teams: [String] { Array(Set(people.compactMap(\.team))).sorted() }
    private var shown: [Person] {
        guard let selected = team ?? teamFilter else { return people }
        return people.filter { $0.team == selected }
    }
    private var unsorted: [Person] { shown.filter { !$0.isSorted } }
    private var groups: [(title: String, people: [Person])] {
        [("Direct reports", shown.filter { $0.role == .report }),
         ("Manager", shown.filter { $0.role == .manager }),
         ("Peers & others", shown.filter { $0.role == .peer || $0.role == .other })]
            .filter { !$0.people.isEmpty }
    }

    var body: some View {
        List {
            if team == nil, !teams.isEmpty {
                Picker("Team", selection: $teamFilter.animation(.snappy)) {
                    Text("All").tag(String?.none)
                    ForEach(teams, id: \.self) { Text($0).tag(String?.some($0)) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            if !unsorted.isEmpty {
                Section("Unsorted · \(unsorted.count)") { ForEach(unsorted) { row($0) } }
            }
            ForEach(groups, id: \.title) { group in
                Section(group.title) { ForEach(group.people) { row($0) } }
            }
            if people.isEmpty {
                ContentUnavailableView("No people yet", systemImage: "person.2",
                                       description: Text("Type from:name or to:name when you capture, and people appear here."))
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .navigationTitle(team ?? "People")
        .navigationDestination(for: Person.self) { PersonView(person: $0) }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink { AllWaitingView() } label: { Label("Waiting", systemImage: "arrow.forward.circle") }
            }
        }
        #endif
    }

    private func row(_ person: Person) -> some View {
        NavigationLink(value: person) {
            HStack(spacing: 6) {
                PersonLabel(person: person)
                Spacer(minLength: 4)
                let owed = person.owed.count
                if owed > 0 { CountPill(text: "\(owed) owe", stale: false) }
                if let days = person.oldestWaitingDays(on: today) {
                    CountPill(text: "\(person.waiting.count) waiting · \(days)d", stale: days >= nudgeAfter)
                }
            }
        }
        .listRowBackground(Color.card)
    }
}

/// Small count capsule; amber when something has waited too long.
struct CountPill: View {
    let text: String
    let stale: Bool

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold).monospacedDigit())
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .foregroundStyle(stale ? Color.orange : Color.accentColor)
            .background((stale ? Color.orange : Color.accentColor).opacity(0.14), in: Capsule())
    }
}
