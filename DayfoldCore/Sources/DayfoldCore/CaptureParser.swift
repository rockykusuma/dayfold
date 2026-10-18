import Foundation

/// Optional inline syntax in captured text. Never required; plain text passes through unchanged.
///
///   #personal / #work      → scope
///   from:priya             → from
///   to:arjun               → to (waiting on)
///   @tomorrow @fri @2026-10-24 → dueOn
///   #anything-else         → tag
public struct ParsedCapture: Equatable, Sendable {
    public var text: String
    public var scope: EntryScope?
    public var from: String?
    public var dueOn: Date?
    public var tags: [String]
    /// `to:name` — waiting on this person.
    public var to: String? = nil
}

public enum CaptureParser {

    public static func parse(_ input: String, now: Date = Date(), calendar: Calendar = .current) -> ParsedCapture {
        var scope: EntryScope?
        var from: String?
        var to: String?
        var dueOn: Date?
        var tags: [String] = []
        var kept: [String] = []

        for token in input.split(separator: " ", omittingEmptySubsequences: true).map(String.init) {
            let lower = token.lowercased()
            if lower == "#work" { scope = .work; continue }
            if lower == "#personal" { scope = .personal; continue }
            if lower.hasPrefix("from:"), let name = personName(token.dropFirst(5)) { from = name; continue }
            if lower.hasPrefix("to:"), let name = personName(token.dropFirst(3)) { to = name; continue }
            if lower.hasPrefix("@"), let date = date(from: String(lower.dropFirst()), now: now, calendar: calendar) {
                dueOn = date; continue
            }
            if lower.hasPrefix("#"), token.count > 1 { tags.append(String(token.dropFirst())); continue }
            kept.append(token)
        }

        return ParsedCapture(text: kept.joined(separator: " "), scope: scope, from: from, dueOn: dueOn, tags: tags, to: to)
    }

    /// A person token without trailing punctuation; nil when nothing is left.
    private static func personName(_ raw: Substring) -> String? {
        let name = raw.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:!?)"))
        return name.isEmpty ? nil : name
    }

    private static let weekdays = ["sun": 1, "mon": 2, "tue": 3, "wed": 4, "thu": 5, "fri": 6, "sat": 7]

    static func date(from token: String, now: Date, calendar: Calendar) -> Date? {
        let today = calendar.startOfDay(for: now)
        switch token {
        case "today": return today
        case "tomorrow", "tmrw": return calendar.date(byAdding: .day, value: 1, to: today)
        default: break
        }
        if let wd = weekdays[String(token.prefix(3))], token.count >= 3,
           ["sun","mon","tue","wed","thu","fri","sat","sunday","monday","tuesday","wednesday","thursday","friday","saturday"].contains(token) {
            // Next occurrence strictly after today.
            var comps = DateComponents(); comps.weekday = wd
            return calendar.nextDate(after: today, matching: comps, matchingPolicy: .nextTime, direction: .forward)
        }
        // ISO yyyy-mm-dd
        let parts = token.split(separator: "-").compactMap { Int($0) }
        if parts.count == 3 {
            return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
        }
        return nil
    }
}
