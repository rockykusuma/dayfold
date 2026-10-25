import Foundation
import SwiftData

/// A journal entry (many per day). CloudKit rules as for `Entry`.
@Model
public final class JournalEntry {
    public var id: UUID = UUID()
    /// When it happened; editable.
    public var date: Date = Date()
    public var title: String = ""
    public var text: String = ""
    public var isBookmarked: Bool = false
    /// The evening Review line (one per day).
    public var isReflection: Bool = false
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    @Relationship(deleteRule: .cascade, inverse: \JournalPhoto.entry) public var photos: [JournalPhoto]?

    public init(id: UUID = UUID(), date: Date = Date(), title: String = "", text: String = "",
                isBookmarked: Bool = false, isReflection: Bool = false,
                createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.date = date
        self.title = title
        self.text = text
        self.isBookmarked = isBookmarked
        self.isReflection = isReflection
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var sortedPhotos: [JournalPhoto] {
        (photos ?? []).sorted { ($0.order, $0.createdAt) < ($1.order, $1.createdAt) }
    }
    public var hasPhotos: Bool { !(photos ?? []).isEmpty }
    public var isBlank: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !hasPhotos
    }
    /// Title if set, else the first non-empty line of the text.
    public var preview: String {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !t.isEmpty { return t }
        return text.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }.first { !$0.isEmpty } ?? ""
    }
}

@Model
public final class JournalPhoto {
    public var id: UUID = UUID()
    @Attribute(.externalStorage) public var data: Data?
    public var order: Double = 0
    public var createdAt: Date = Date()
    public var entry: JournalEntry?

    public init(data: Data?, order: Double, createdAt: Date = Date()) {
        self.data = data
        self.order = order
        self.createdAt = createdAt
    }
}

public enum Journal {
    /// The `isReflection` entry on that calendar day (oldest `createdAt` if several).
    public static func reflection(for day: Date, calendar: Calendar = .current, in context: ModelContext) throws -> JournalEntry? {
        try reflections(on: day, calendar: calendar, in: context).first
    }

    /// Trims; empty clears the day's reflection text(s), deleting only those left blank (a title or photos
    /// keep it), otherwise updates or inserts (dated 21:00 that day). Does not save.
    public static func setReflection(_ text: String, for day: Date, now: Date = Date(), calendar: Calendar = .current,
                                     in context: ModelContext) throws {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let existing = try reflections(on: day, calendar: calendar, in: context)
        if text.isEmpty {
            for entry in existing {
                entry.text = ""
                entry.updatedAt = now
                if entry.isBlank { context.delete(entry) }
            }
        } else if let entry = existing.first {
            entry.text = text
            entry.updatedAt = now
        } else {
            context.insert(JournalEntry(date: evening(of: day, calendar), text: text, isReflection: true,
                                        createdAt: now, updatedAt: now))
        }
    }

    /// Each `DayNote` becomes a reflection entry with the note's id (so copies made by two devices
    /// collapse in `dedupe`), then the note is deleted. Does not save.
    public static func migrateDayNotes(calendar: Calendar = .current, in context: ModelContext) throws {
        for note in try context.fetch(FetchDescriptor<DayNote>()) {
            defer { context.delete(note) }
            guard !note.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            context.insert(JournalEntry(id: note.id, date: evening(of: note.day, calendar), text: note.text,
                                        isReflection: true, createdAt: note.updatedAt, updatedAt: note.updatedAt))
        }
    }

    /// (a) Entries sharing an id: keep the newest `updatedAt`. (b) Several reflections on one calendar
    /// day: keep the oldest, join distinct texts in `updatedAt` order, take the newest `updatedAt`.
    /// Plain entries are never merged by day. Does not save.
    public static func dedupe(calendar: Calendar = .current, in context: ModelContext) throws {
        var survivors: [JournalEntry] = []
        for group in Dictionary(grouping: try context.fetch(FetchDescriptor<JournalEntry>()), by: \.id).values {
            let keeper = group.max { $0.updatedAt < $1.updatedAt }!
            for loser in group where loser !== keeper { absorb(loser, into: keeper, in: context) }
            survivors.append(keeper)
        }
        let byDay = Dictionary(grouping: survivors.filter(\.isReflection)) { calendar.startOfDay(for: $0.date) }
        for group in byDay.values where group.count > 1 {
            let ordered = group.sorted { ($0.updatedAt, $0.id.uuidString) < ($1.updatedAt, $1.id.uuidString) }
            // The merged entry keeps one title (the first set, see `absorb`); any other title becomes the
            // first line of its own text so it survives the join.
            let titles = ordered.map { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) }
            let kept = titles.first { !$0.isEmpty } ?? ""
            for (loser, title) in zip(ordered, titles).dropFirst() {
                if !title.isEmpty, title != kept {
                    loser.text = loser.text.isEmpty ? title : title + "\n" + loser.text
                }
            }
            var texts: [String] = []
            for t in ordered.map(\.text) where !t.isEmpty && !texts.contains(t) { texts.append(t) }
            ordered[0].text = texts.joined(separator: "\n")
            ordered[0].updatedAt = ordered.last!.updatedAt
            for loser in ordered.dropFirst() { absorb(loser, into: ordered[0], in: context) }
        }
    }

    /// Deletes `loser` but keeps its photos (after the keeper's), bookmark and title.
    private static func absorb(_ loser: JournalEntry, into keeper: JournalEntry, in context: ModelContext) {
        var next = (keeper.sortedPhotos.last?.order ?? -1) + 1
        for photo in loser.sortedPhotos {
            photo.entry = keeper
            photo.order = next
            next += 1
        }
        keeper.isBookmarked = keeper.isBookmarked || loser.isBookmarked
        if keeper.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { keeper.title = loser.title }
        context.delete(loser)
    }

    private static func evening(of day: Date, _ calendar: Calendar) -> Date {
        calendar.date(bySettingHour: 21, minute: 0, second: 0, of: day) ?? day
    }

    private static func reflections(on day: Date, calendar: Calendar, in context: ModelContext) throws -> [JournalEntry] {
        try context.fetch(FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor(\.createdAt)]))
            .filter { $0.isReflection && calendar.isDate($0.date, inSameDayAs: day) }
    }
}
