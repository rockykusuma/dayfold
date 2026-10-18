#if DEBUG
import Foundation
import SwiftData
import DayfoldCore

/// Launch with `-demo` (or use in previews) for an in-memory store filled with a realistic day.
/// Debug builds only; never touches iCloud.
enum DemoData {
    static var isEnabled: Bool { CommandLine.arguments.contains("-demo") }

    @MainActor
    static func container() -> ModelContainer {
        let container = try! ModelContainer(for: Entry.self, Person.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        func at(_ daysAgo: Int, _ hour: Int, _ minute: Int) -> Date {
            cal.date(byAdding: DateComponents(day: -daysAgo, hour: hour, minute: minute), to: today)!
        }
        let samples: [Entry] = [
            Entry(text: "Send Q4 hiring plan to leadership", createdAt: at(5, 9, 10), from: "Meera"),
            Entry(text: "Review Arjun's design doc for the sync service", createdAt: at(2, 14, 30), from: "Arjun"),
            Entry(text: "Book dentist appointment", scope: .personal, createdAt: at(1, 19, 5)),
            Entry(text: "Unblock the release: sign off on the migration checklist", createdAt: at(0, 9, 2),
                  dueOn: cal.date(byAdding: .day, value: 2, to: today), from: "Priya"),
            Entry(text: "1:1 with Sam — wants to move to the platform team. Talk again Friday.", kind: .note, createdAt: at(0, 11, 40)),
            Entry(text: "Share interview feedback for the backend candidate", createdAt: at(0, 13, 15), from: "HR"),
            Entry(text: "Pick up groceries", scope: .personal, createdAt: at(0, 17, 20)),
        ]
        samples.forEach(container.mainContext.insert)
        samples[1].status = .inProgress
        Review.apply(.done, to: samples[5], now: at(0, 16, 0))
        return container
    }
}
#endif
