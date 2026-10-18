import Foundation

/// The fields the day-page and review rules need. `Entry` conforms; tests use a plain struct.
public protocol DayPageItem {
    var createdAt: Date { get }
    var kind: EntryKind { get }
    var status: EntryStatus { get }
    var closedAt: Date? { get }
    var showOn: Date { get }
    var link: PersonLink? { get }
    var delegatedAt: Date? { get }
    var nudgedAt: Date? { get }
    var isPriority: Bool { get }
}

public extension DayPageItem {
    /// An open task R handed to someone else.
    var isWaiting: Bool { kind == .task && link == .to && status.isActive }
}

/// A day page is a *view*, not storage. Carry-forward is a rule, not a copy:
/// an active task simply appears on every day from `showOn` onward until it is closed.
/// Looking back at a past day therefore shows exactly what was open on that day.
public enum DayPage {

    /// Whether `item` belongs on the page for `day`.
    public static func contains<Item: DayPageItem>(_ item: Item, on day: Date, calendar: Calendar = .current) -> Bool {
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return false }

        switch item.kind {
        case .note:
            // Notes belong to the day they were written. Never carry forward.
            return item.createdAt >= start && item.createdAt < end

        case .task:
            // Not yet visible: scheduled for a later day.
            guard item.showOn < end else { return false }

            if item.status.isActive {
                // Active: on every page from showOn onward (this is the carry-forward).
                return true
            }

            // Closed: shown on the day it was closed only, so history stays accurate.
            guard let closedAt = item.closedAt else { return false }
            return closedAt >= start && closedAt < end
        }
    }

    public static func items<Item: DayPageItem>(_ items: [Item], on day: Date, calendar: Calendar = .current) -> [Item] {
        items.filter { contains($0, on: day, calendar: calendar) }
    }

    /// Whole days between capture and `day`. Drives the age badge ("asked 4d ago").
    public static func age<Item: DayPageItem>(of item: Item, on day: Date, calendar: Calendar = .current) -> Int {
        let from = calendar.startOfDay(for: item.createdAt)
        let to = calendar.startOfDay(for: day)
        return max(0, calendar.dateComponents([.day], from: from, to: to).day ?? 0)
    }
}
