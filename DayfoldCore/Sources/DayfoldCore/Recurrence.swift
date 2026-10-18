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
}
