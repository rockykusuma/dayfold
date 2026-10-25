import Foundation

public struct CalendarDay: Identifiable, Equatable {
    public let date: Date
    public let day: Int
    public let doneCount: Int
    public let hasEntry: Bool
    public let isToday: Bool
    public let isFuture: Bool
    public var id: Date { date }
}

/// The Journal tab's month calendar and counts. Pure rules; the view only draws them.
public struct JournalInsights {
    public let month: DateInterval
    /// Rows of 7 from `calendar.firstWeekday`; `nil` pads before the 1st and after the last day.
    public let weeks: [[CalendarDay?]]
    public let entriesThisYear: Int
    public let daysWrittenThisMonth: Int

    public init(entries: [JournalEntry], tasks: [Entry], containing date: Date, today: Date, calendar: Calendar = .current) {
        let month = calendar.dateInterval(of: .month, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 86_400)
        let start = { calendar.startOfDay(for: $0) }
        let written = Set(entries.map { start($0.date) })
        var done: [Date: Int] = [:]
        for t in tasks where t.kind == .task && t.status == .done {
            if let c = t.closedAt { done[start(c), default: 0] += 1 }
        }
        let todayStart = start(today)
        let count = calendar.range(of: .day, in: .month, for: month.start)?.count ?? 0
        let days: [CalendarDay] = (0..<count).compactMap { i in
            guard let d = calendar.date(byAdding: .day, value: i, to: month.start) else { return nil }
            return CalendarDay(date: d, day: i + 1, doneCount: done[d] ?? 0, hasEntry: written.contains(d),
                               isToday: d == todayStart, isFuture: d > todayStart)
        }
        let lead = (calendar.component(.weekday, from: month.start) - calendar.firstWeekday + 7) % 7
        var cells: [CalendarDay?] = Array(repeating: nil, count: lead) + days
        cells += Array(repeating: nil, count: (7 - cells.count % 7) % 7)

        self.month = month
        self.weeks = stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<$0 + 7]) }
        self.entriesThisYear = entries.filter { calendar.isDate($0.date, equalTo: today, toGranularity: .year) }.count
        self.daysWrittenThisMonth = written.filter { month.start <= $0 && $0 < month.end }.count
    }

    /// Shade for a day's done count: 0, 1-2, 3-5, 6+.
    public static func level(for doneCount: Int) -> Int {
        switch doneCount {
        case ..<1: 0
        case 1...2: 1
        case 3...5: 2
        default: 3
        }
    }
}
