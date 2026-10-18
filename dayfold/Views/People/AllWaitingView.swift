import SwiftUI
import SwiftData
import DayfoldCore

/// Everything R is waiting on, grouped by person, longest wait first.
struct AllWaitingView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]
    @State private var opened: Person?
    private let today = Calendar.current.startOfDay(for: Date())

    var body: some View {
        let groups = PersonPage.allWaiting(people, on: today)
        List {
            ForEach(groups) { group in
                Section("\(group.person.name) · \(group.oldestDays)d") {
                    ForEach(group.entries) { entry in
                        EntryRow(entry: entry, day: today, showScope: false) {
                            withAnimation(.snappy) { Review.apply(.done, to: entry, context: context) }
                        } onPerson: { opened = $0 }
                    }
                }
            }
            if groups.isEmpty {
                ContentUnavailableView("Not waiting on anyone", systemImage: "checkmark.circle",
                                       description: Text("Delegate a task or type to:name to track it here."))
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .navigationTitle("Waiting")
        .navigationDestination(item: $opened) { PersonView(person: $0) }
    }
}
