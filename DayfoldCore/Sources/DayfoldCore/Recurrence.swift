import Foundation
import SwiftData

public enum Recurrence {
    /// The next day a repeating task shows on: the first date the rule allows that is
    /// after both `showOn` and `closedOn`, so closing late never creates catch-up copies.
    /// Steps with calendar arithmetic (never seconds), so the result is local midnight across DST.
    public static func nextShowOn(rule: RepeatRule, after showOn: Date, closedOn: Date, calendar: Calendar = .current) -> Date {
        let base = max(calendar.startOfDay(for: showOn), calendar.startOfDay(for: closedOn))
        func dayAfter(_ d: Date) -> Date { calendar.date(byAdding: .day, value: 1, to: d)! }
        var d = dayAfter(base)
        switch rule {
        case .daily:
            return d
        case .weekdays:   // Mon–Fri by weekday number, not locale weekend
            while [1, 7].contains(calendar.component(.weekday, from: d)) { d = dayAfter(d) }
            return d
        case .weekly:
            let target = calendar.component(.weekday, from: showOn)
            while calendar.component(.weekday, from: d) != target { d = dayAfter(d) }
            return d
        case .monthly(let day):
            let anchor = day ?? calendar.component(.day, from: showOn)
            var month = calendar.dateInterval(of: .month, for: base)!.start
            while true {   // at most two passes
                let length = calendar.range(of: .day, in: .month, for: month)!.count
                let candidate = calendar.date(byAdding: .day, value: min(anchor, length) - 1, to: month)!
                if candidate > base { return candidate }
                month = calendar.date(byAdding: .month, value: 1, to: month)!
            }
        }
    }

    /// Creates the next occurrence of a repeating task that was just closed. Nil for notes,
    /// one-off tasks, or when a later occurrence is already active (done, undo, done again).
    @discardableResult
    public static func spawnNext(from entry: Entry, closedOn: Date, now: Date = Date(),
                                 in context: ModelContext, calendar: Calendar = .current) -> Entry? {
        guard entry.kind == .task, let rule = entry.repeatRule else { return nil }
        // The first occurrence's id, so devices that each start the series agree on it.
        entry.seriesID = entry.seriesID ?? entry.id
        let sid: UUID? = entry.seriesID
        let siblings = (try? context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.seriesID == sid }))) ?? []
        if siblings.contains(where: { $0.status.isActive && $0.showOn > entry.showOn }) { return nil }

        let showOn = nextShowOn(rule: rule, after: entry.showOn, closedOn: closedOn, calendar: calendar)
        // Dated to its own day at the original time of day, so it never looks old or stale.
        let t = calendar.dateComponents([.hour, .minute, .second], from: entry.createdAt)
        let created = calendar.date(bySettingHour: t.hour ?? 0, minute: t.minute ?? 0, second: t.second ?? 0, of: showOn) ?? showOn
        let next = Entry(text: entry.text, kind: .task, scope: entry.scope, createdAt: created, showOn: showOn,
                         from: entry.from, tags: entry.tags, calendar: calendar)
        context.insert(next)
        next.isPriority = entry.isPriority
        next.repeatRaw = entry.repeatRaw
        next.seriesID = sid
        if let due = entry.dueOn {
            let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: entry.showOn),
                                               to: calendar.startOfDay(for: due)).day ?? 0
            next.dueOn = calendar.date(byAdding: .day, value: days, to: showOn)
        }
        if let person = entry.person {
            if entry.link == .to {
                Review.delegate(next, to: person, now: created)
            } else {
                next.person = person
                next.linkRaw = entry.linkRaw
            }
        }
        for item in entry.checklist ?? [] {
            let copy = ChecklistItem(text: item.text, order: item.order, createdAt: now)
            context.insert(copy)
            copy.entry = next
        }
        return next
    }

    /// Two devices can each spawn the same occurrence. Keeps the oldest of every active
    /// (series, showOn) group and deletes the rest. Spawned copies share `createdAt`, so ties
    /// break on id: every device keeps the same one.
    public static func dedupe(in context: ModelContext) throws {
        let entries = try context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.seriesID != nil }))
            .sorted { ($0.createdAt, $0.id.uuidString) < ($1.createdAt, $1.id.uuidString) }
        var seen = Set<String>()
        for e in entries where e.status.isActive {
            if !seen.insert("\(e.seriesID!)|\(e.showOn.timeIntervalSince1970)").inserted { context.delete(e) }
        }
    }
}
