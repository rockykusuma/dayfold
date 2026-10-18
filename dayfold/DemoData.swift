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
        let ctx = container.mainContext
        let priya = Person(name: "Priya Sharma", role: .report, team: "Platform")
        let arjun = Person(name: "Arjun", role: .report, team: "Sync")
        let sam = Person(name: "Sam K", role: .report, team: "Platform")
        let meera = Person(name: "Meera", role: .manager)
        let hr = Person(name: "HR")                     // unsorted
        [priya, arjun, meera, sam].forEach { $0.isSorted = true }
        [priya, arjun, sam, meera, hr].forEach(ctx.insert)

        func link(_ e: Entry, _ p: Person, _ l: PersonLink) { e.person = p; e.link = l }
        link(samples[0], meera, .from)        // Q4 hiring plan, from Meera
        link(samples[1], arjun, .from)        // Arjun's design doc
        link(samples[3], priya, .from)        // migration checklist
        link(samples[5], hr, .from)           // interview feedback (done)
        link(samples[4], sam, .about)         // 1:1 note about Sam

        let capacity = Entry(text: "Q4 capacity numbers", createdAt: at(6, 10, 0))
        let syncDoc = Entry(text: "Sync service rollout plan", createdAt: at(1, 15, 0))
        let vendor = Entry(text: "Vendor security questionnaire", createdAt: at(8, 11, 0))
        [capacity, syncDoc, vendor].forEach(ctx.insert)
        Review.delegate(capacity, to: priya, now: at(6, 10, 5))     // stale
        Review.delegate(syncDoc, to: arjun, now: at(1, 15, 5))      // fresh
        Review.delegate(vendor, to: arjun, now: at(8, 11, 5))
        vendor.nudgedAt = at(2, 9, 0)                               // nudged, not yet stale

        let note = Entry(text: "Wants more ownership of on-call tooling", kind: .note, createdAt: at(0, 12, 30))
        ctx.insert(note); link(note, priya, .about)
        return container
    }
}
#endif
