import Foundation

public enum JournalFeedFilter: String, CaseIterable, Identifiable {
    case all = "All", bookmarked = "Bookmarked", withPhotos = "With photos"
    public var id: String { rawValue }
}

public struct JournalMonth: Identifiable {
    /// Start of the month.
    public let id: Date
    public internal(set) var entries: [JournalEntry]
}

/// The Journal tab's feed rules.
public enum JournalFeed {
    public static func filter(_ entries: [JournalEntry], kind: JournalFeedFilter, day: Date?,
                              calendar: Calendar = .current) -> [JournalEntry] {
        entries.filter { e in
            let kept = switch kind {
            case .all: true
            case .bookmarked: e.isBookmarked
            case .withPhotos: e.hasPhotos
            }
            return kept && (day.map { calendar.isDate(e.date, inSameDayAs: $0) } ?? true)
        }
    }

    /// Months newest first, each with its entries newest first.
    public static func months(_ entries: [JournalEntry], calendar: Calendar = .current) -> [JournalMonth] {
        var groups: [JournalMonth] = []
        for e in entries.sorted(by: { $0.date > $1.date }) {
            let m = calendar.dateInterval(of: .month, for: e.date)?.start ?? e.date
            if groups.last?.id == m {
                groups[groups.count - 1].entries.append(e)
            } else {
                groups.append(JournalMonth(id: m, entries: [e]))
            }
        }
        return groups
    }
}
