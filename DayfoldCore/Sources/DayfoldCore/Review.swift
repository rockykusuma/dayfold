import Foundation

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
}

public enum Review {

    /// Tasks that need a decision in tonight's Review for `day`: active and already visible.
    public static func pending<Item: DayPageItem>(_ items: [Item], on day: Date, calendar: Calendar = .current) -> [Item] {
        items.filter { $0.kind == .task && $0.status.isActive && DayPage.contains($0, on: day, calendar: calendar) }
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
        }
    }

    /// Reopen a closed task (undo from the day page).
    public static func reopen(_ entry: Entry) {
        entry.status = .open
        entry.closedAt = nil
    }
}
