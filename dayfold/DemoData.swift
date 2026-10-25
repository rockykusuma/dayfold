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
        let container = try! ModelContainer(for: Entry.self, Person.self, ChecklistItem.self, DayNote.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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

        samples[0].isPriority = true; samples[0].tags = ["hiring"]
        samples[3].isPriority = true; samples[3].tags = ["release"]
        samples[5].tags = ["hiring"]
        samples[4].tags = ["1on1"]
        for t in ["Run dry-run", "Sign rollback plan", "Notify on-call"] { Checklist.add(t, to: samples[3], in: ctx) }
        samples[3].sortedChecklist.first?.isDone = true

        let weekly = Entry(text: "Weekly status report", createdAt: at(7, 9, 0))
        ctx.insert(weekly)
        weekly.tags = ["reports"]
        weekly.setRepeat(.weekly(weekday: nil))
        Review.apply(.done, to: weekly, now: at(0, 9, 30), context: ctx)
        let plants = Entry(text: "Water the plants", scope: .personal, createdAt: at(0, 8, 0))
        ctx.insert(plants)
        plants.setRepeat(.daily)

        // Week page: closed across this week (clamped to its first day so they never slip into last week).
        let weekStart = cal.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let intoWeek = cal.dateComponents([.day], from: weekStart, to: today).day ?? 0
        func closed(_ daysAgo: Int, _ hour: Int) -> Date { at(min(daysAgo, intoWeek), hour, 0) }
        let boardSlides = Entry(text: "Hiring slides for the board pack", createdAt: at(6, 9, 30))
        let escalations = Entry(text: "Summarise last month's customer escalations", createdAt: at(5, 10, 15))
        let flaky = Entry(text: "Fix the flaky sync tests", createdAt: at(5, 14, 0))
        let offsite = Entry(text: "Book the team offsite venue", createdAt: at(4, 11, 0))
        let dashboards = Entry(text: "Migrate the old alert dashboards", createdAt: at(6, 16, 0))
        let rotation = Entry(text: "Draft the November on-call rotation", createdAt: at(4, 10, 20))   // stuck
        [boardSlides, escalations, flaky, offsite, dashboards, rotation].forEach(ctx.insert)
        link(boardSlides, meera, .from)
        link(escalations, meera, .from)
        Review.delegate(flaky, to: arjun, now: at(5, 14, 5))
        Review.apply(.done, to: boardSlides, now: closed(3, 15))
        Review.apply(.done, to: escalations, now: closed(1, 11))
        Review.apply(.done, to: flaky, now: closed(2, 17))
        Review.apply(.done, to: offsite, now: closed(4, 12))
        Review.apply(.drop, to: dashboards, now: closed(2, 10))
        ctx.insert(DayNote(day: at(1, 0, 0), text: "Long day of interviews. The migration finally feels close."))
        ctx.insert(DayNote(day: at(2, 0, 0), text: "Quiet morning, good focus on the sync doc."))
        return container
    }
}
#endif
