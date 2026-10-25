import Foundation
import SwiftData

/// An optional one-line note for a calendar day. CloudKit rules as for `Entry`.
@Model
public final class DayNote {
    public var id: UUID = UUID()
    /// Start of the calendar day.
    public var day: Date = Calendar.current.startOfDay(for: Date())
    public var text: String = ""
    public var updatedAt: Date = Date()

    public init(day: Date, text: String, updatedAt: Date = Date(), calendar: Calendar = .current) {
        self.day = calendar.startOfDay(for: day)
        self.text = text
        self.updatedAt = updatedAt
    }
}

public enum DayNotes {
    public static func note(for day: Date, calendar: Calendar = .current, in context: ModelContext) throws -> DayNote? {
        try notes(on: day, calendar: calendar, in: context).first
    }

    /// Trims; empty deletes the day's note(s), otherwise updates or inserts. Does not save.
    public static func set(_ text: String, for day: Date, now: Date = Date(), calendar: Calendar = .current,
                           in context: ModelContext) throws {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let existing = try notes(on: day, calendar: calendar, in: context)
        if text.isEmpty {
            existing.forEach(context.delete)
        } else if let note = existing.first {
            note.text = text
            note.updatedAt = now
        } else {
            context.insert(DayNote(day: day, text: text, updatedAt: now, calendar: calendar))
        }
    }

    /// Two devices can each create a note for the same day. Keep the oldest, join the distinct
    /// texts in `updatedAt` order, take the newest `updatedAt`. Does not save.
    public static func dedupe(calendar: Calendar = .current, in context: ModelContext) throws {
        let all = try context.fetch(FetchDescriptor<DayNote>())
        for group in Dictionary(grouping: all, by: { calendar.startOfDay(for: $0.day) }).values where group.count > 1 {
            let ordered = group.sorted { ($0.updatedAt, $0.id.uuidString) < ($1.updatedAt, $1.id.uuidString) }
            var texts: [String] = []
            for t in ordered.map(\.text) where !t.isEmpty && !texts.contains(t) { texts.append(t) }
            let keeper = ordered[0]
            keeper.text = texts.joined(separator: "\n")
            keeper.updatedAt = ordered.last!.updatedAt
            ordered.dropFirst().forEach(context.delete)
        }
    }

    private static func notes(on day: Date, calendar: Calendar, in context: ModelContext) throws -> [DayNote] {
        try context.fetch(FetchDescriptor<DayNote>(sortBy: [SortDescriptor(\.updatedAt)]))
            .filter { calendar.isDate($0.day, inSameDayAs: day) }
    }
}
