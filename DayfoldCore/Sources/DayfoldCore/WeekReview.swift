import Foundation

/// Entries grouped under one person; `person == nil` is the "Everything else" group.
public struct PersonGroup: Identifiable {
    public let id: String
    public let person: Person?
    public let entries: [Entry]

    init(person: Person?, entries: [Entry]) {
        self.id = person?.id.uuidString ?? "none"
        self.person = person
        self.entries = entries
    }
}

/// One week of closed, stuck and waiting tasks plus day notes. Pure rules; the Week screen only displays it.
public struct WeekReview {
    public let interval: DateInterval
    public let isCurrent: Bool
    public let done: [PersonGroup]
    public let droppedCount: Int
    /// Current week only: own tasks open 3+ days (the amber threshold).
    public let stuck: [Entry]
    /// Current week only.
    public let waiting: [PersonGroup]
    public let notes: [DayNote]
    private let today: Date

    public var isEmpty: Bool { done.isEmpty && stuck.isEmpty && waiting.isEmpty && notes.isEmpty && droppedCount == 0 }

    public init(entries: [Entry], notes: [DayNote], containing date: Date, today: Date, calendar: Calendar = .current) {
        let interval = calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: calendar.startOfDay(for: date), duration: 7 * 86_400)
        let inWeek = { (d: Date?) in d.map { interval.start <= $0 && $0 < interval.end } ?? false }
        let tasks = entries.filter { $0.kind == .task }
        let isCurrent = interval.start <= today && today < interval.end

        let closed = tasks.filter { inWeek($0.closedAt) }
        let done = closed.filter { $0.status == .done }.sorted { $0.closedAt! < $1.closedAt! }
        let named = Dictionary(grouping: done.filter { $0.person != nil }, by: { $0.person!.id })
            .values
            .sorted { a, b in
                a.count != b.count ? a.count > b.count
                    : a[0].person!.name.localizedStandardCompare(b[0].person!.name) == .orderedAscending
            }
        let rest = done.filter { $0.person == nil }

        let active = tasks.filter { $0.status.isActive }
        let waitingByPerson = Dictionary(grouping: active.filter(\.isWaiting), by: { $0.person!.id })
            .values
            .map { $0.sorted { ($0.delegatedAt ?? $0.createdAt) < ($1.delegatedAt ?? $1.createdAt) } }
            .sorted { ($0[0].delegatedAt ?? $0[0].createdAt) < ($1[0].delegatedAt ?? $1[0].createdAt) }

        self.interval = interval
        self.isCurrent = isCurrent
        self.today = today
        self.done = named.map { PersonGroup(person: $0[0].person, entries: $0) }
            + (rest.isEmpty ? [] : [PersonGroup(person: nil, entries: rest)])
        self.droppedCount = closed.filter { $0.status == .dropped }.count
        self.stuck = !isCurrent ? [] : active
            .filter { !$0.isWaiting && $0.showOn <= today && DayPage.age(of: $0, on: today, calendar: calendar) >= 3 }
            .sorted { $0.createdAt < $1.createdAt }
        self.waiting = isCurrent ? waitingByPerson.map { PersonGroup(person: $0[0].person, entries: $0) } : []
        self.notes = notes.filter { inWeek($0.day) }.sorted { $0.day < $1.day }
    }

    /// Plain-text update for sharing. Never includes day notes. Empty sections are omitted.
    public func summaryText(title: String, calendar: Calendar = .current) -> String {
        var lines = [title]
        let doneEntries = done.flatMap(\.entries)
        if !doneEntries.isEmpty {
            lines.append("Done (\(doneEntries.count))")
            lines += doneEntries.map { e in "• " + e.text + (e.person.map { " — \($0.name)" } ?? "") }
        }
        if !stuck.isEmpty {
            lines.append("Still open (\(stuck.count))")
            lines += stuck.map { "• \($0.text) (\(DayPage.age(of: $0, on: today, calendar: calendar))d)" }
        }
        let waitingEntries = waiting.flatMap(\.entries)
        if !waitingEntries.isEmpty {
            lines.append("Waiting on (\(waitingEntries.count))")
            lines += waitingEntries.map { "• \($0.person?.name ?? ""): \($0.text) (\(Review.waitingDays($0, on: today, calendar: calendar))d)" }
        }
        return lines.joined(separator: "\n")
    }
}
