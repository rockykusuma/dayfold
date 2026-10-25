#if DEBUG
import Foundation
import SwiftData
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import DayfoldCore

/// Launch with `-demo` (or use in previews) for an in-memory store filled with a realistic day.
/// Debug builds only; never touches iCloud.
enum DemoData {
    static var isEnabled: Bool { CommandLine.arguments.contains("-demo") }

    @MainActor
    static func container() -> ModelContainer {
        let container = try! ModelContainer(for: Entry.self, Person.self, ChecklistItem.self, DayNote.self, JournalEntry.self, JournalPhoto.self, NotePage.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
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
        ctx.insert(DayNote(day: at(2, 0, 0), text: "Quiet morning, good focus on the sync doc."))   // migrated by the first tidy

        // Journal over the last 10 days (the two DayNotes above become reflections on days 1 and 2).
        func journal(_ daysAgo: Int, _ hour: Int, _ minute: Int, title: String = "", _ text: String,
                     bookmarked: Bool = false, reflection: Bool = false, photos: [(CGFloat, CGFloat, CGFloat)] = []) {
            let when = at(daysAgo, hour, minute)
            let e = JournalEntry(date: when, title: title, text: text, isBookmarked: bookmarked,
                                 isReflection: reflection, createdAt: when, updatedAt: when)
            ctx.insert(e)
            for (i, rgb) in photos.enumerated() {
                let photo = JournalPhoto(data: solidPhoto(rgb), order: Double(i), createdAt: when)
                ctx.insert(photo)
                photo.entry = e
            }
        }
        journal(0, 8, 15, "Slept well for once. Want to keep the afternoon clear for the release sign-off.")
        journal(3, 15, 30, title: "Offsite planning",
                "Two days, somewhere we can walk. Morning on the platform roadmap, afternoon for the on-call pain list. Ask Meera about budget before booking.",
                bookmarked: true)
        journal(5, 21, 0, "Escalations summary took longer than it should. Felt scattered after lunch.", reflection: true)
        journal(6, 18, 40, title: "Whiteboard from the sync review",
                "Arjun's diagram finally made the conflict rules click.", photos: [(0.36, 0.52, 0.66)])
        journal(9, 12, 10, "Lunch by the lake with the team. Sam talked about wanting more platform work.",
                photos: [(0.55, 0.68, 0.45), (0.85, 0.66, 0.42)])

        // Notes (wiki): a small linked tree, one pinned page, one subpage.
        func page(_ title: String, _ body: String, pinned: Bool = false, daysAgo: Int) -> NotePage {
            let when = at(daysAgo, 10, 0)
            let p = NotePage(title: title, body: body, isPinned: pinned, createdAt: when, updatedAt: when)
            ctx.insert(p)
            return p
        }
        _ = page("Release process", """
            Every other Thursday, owned by the on-call lead.

            ## Before the cut
            - Freeze the main branch at noon
            - Run the dry-run and check the migration checklist
              - Rollback plan signed off
            - Post the release notes draft in #platform

            ## Ship it
            1. Tag the build
            2. Run the script, ~~by hand~~ from CI
            ```
            ./scripts/release --tag v2.4
            ```

            > If in doubt, ++don't++ ship on a _Friday_.
            """, daysAgo: 3)
        _ = page("Team — Platform", """
            Owns sync, on-call tooling and the release train.

            ## Links
            - [[Release process]]
            - [[Onboarding]] for new joiners
            """, pinned: true, daysAgo: 1)
        let onboarding = page("Onboarding", """
            First week for anyone joining the team.

            - [x] Laptop and accounts
            - [ ] Shadow an on-call shift
            - [ ] Ship a small fix
            """, daysAgo: 6)
        let laptop = page("Laptop setup", """
            Install Xcode and the command line tools, then clone the repo.
            Read [[Release process]] before your first ship.
            """, daysAgo: 6)
        laptop.parent = onboarding
        return container
    }

    /// A small solid-colour image, imported the way picked photos are.
    private static func solidPhoto(_ rgb: (CGFloat, CGFloat, CGFloat)) -> Data? {
        let size = 600
        guard let cg = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                                 space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        else { return nil }
        cg.setFillColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        cg.fill(CGRect(x: 0, y: 0, width: size, height: size))
        let png = NSMutableData()
        guard let image = cg.makeImage(),
              let dest = CGImageDestinationCreateWithData(png, UTType.png.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else { return nil }
        return PhotoImport.downscaled(png as Data)
    }
}
#endif
