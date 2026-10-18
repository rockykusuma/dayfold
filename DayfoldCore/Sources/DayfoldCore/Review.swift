import Foundation
import SwiftData

/// The four choices in the evening Review, one card per active task.
public enum ReviewAction: Equatable, Sendable {
    /// Finished. Closes the task today.
    case done
    /// Still working on it. Marks in-progress; it carries into tomorrow.
    case stillGoing
    /// Not now. Hide it until `date`.
    case push(to: Date)
    /// Never mind. Closes the task today without completing it.
    case drop
    /// Followed up on a waiting item today. Restarts its waiting clock.
    case nudged
}

public enum Review {

    /// R's own tasks needing a decision tonight: active, visible on `day`, not waiting on someone.
    public static func pending<Item: DayPageItem>(_ items: [Item], on day: Date, calendar: Calendar = .current) -> [Item] {
        items.filter { $0.kind == .task && $0.status.isActive && !$0.isWaiting && DayPage.contains($0, on: day, calendar: calendar) }
    }

    /// Whole days a waiting item has waited since the last follow-up (else delegation, else capture).
    public static func waitingDays<Item: DayPageItem>(_ item: Item, on day: Date, calendar: Calendar = .current) -> Int {
        let since = calendar.startOfDay(for: item.nudgedAt ?? item.delegatedAt ?? item.createdAt)
        let to = calendar.startOfDay(for: day)
        return max(0, calendar.dateComponents([.day], from: since, to: to).day ?? 0)
    }

    /// Waiting items that have waited `days` or more, oldest wait first.
    public static func staleWaiting<Item: DayPageItem>(_ items: [Item], on day: Date, after days: Int, calendar: Calendar = .current) -> [Item] {
        items
            .filter { $0.isWaiting && DayPage.contains($0, on: day, calendar: calendar) && waitingDays($0, on: day, calendar: calendar) >= days }
            .sorted { waitingDays($0, on: day, calendar: calendar) > waitingDays($1, on: day, calendar: calendar) }
    }

    /// Tonight's Review: own tasks, then stale waiting items.
    public static func queue<Item: DayPageItem>(_ items: [Item], on day: Date, nudgeAfter days: Int, calendar: Calendar = .current) -> [Item] {
        pending(items, on: day, calendar: calendar) + staleWaiting(items, on: day, after: days, calendar: calendar)
    }

    /// Hand a task to someone. Keeps "who asked" as `from` text when it came from another person.
    public static func delegate(_ entry: Entry, to person: Person, now: Date = Date()) {
        if entry.link == .from, let askedBy = entry.person?.name { entry.from = askedBy }
        entry.person = person
        entry.link = .to
        entry.delegatedAt = now
        entry.nudgedAt = nil
        entry.status = .open
        entry.closedAt = nil
    }

    /// Apply one Review decision. `now` is when the decision is made.
    public static func apply(_ action: ReviewAction, to entry: Entry, now: Date = Date(), calendar: Calendar = .current) {
        switch action {
        case .done:
            entry.status = .done
            entry.closedAt = now
        case .stillGoing:
            entry.status = .inProgress
        case .push(let date):
            entry.showOn = calendar.startOfDay(for: date)
        case .drop:
            entry.status = .dropped
            entry.closedAt = now
        case .nudged:
            entry.nudgedAt = now
        }
    }

    /// As `apply`, and a repeating task closed with done/drop gets its next occurrence.
    public static func apply(_ action: ReviewAction, to entry: Entry, now: Date = Date(),
                             calendar: Calendar = .current, context: ModelContext) {
        apply(action, to: entry, now: now, calendar: calendar)
        if action == .done || action == .drop {
            Recurrence.spawnNext(from: entry, closedOn: now, now: now, in: context, calendar: calendar)
        }
    }

    /// Reopen a closed task (undo from the day page).
    public static func reopen(_ entry: Entry) {
        entry.status = .open
        entry.closedAt = nil
    }
}
