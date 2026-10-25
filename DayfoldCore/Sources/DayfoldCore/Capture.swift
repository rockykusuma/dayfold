import Foundation
import SwiftData

/// The one path every entry point (capture bar, Siri, Services, hotkey panel) adds entries through.
public enum Capture {
    /// Link every capture to this person, e.g. from a person page.
    public struct Link {
        public let person: Person
        public let link: PersonLink
        public init(person: Person, link: PersonLink) { self.person = person; self.link = link }
    }

    /// Parses, builds and inserts one entry; nil for blank text. Does not save.
    @discardableResult
    public static func add(_ text: String, kind: EntryKind = .task, scope: EntryScope, day: Date,
                           linkedTo: Link? = nil, now: Date = Date(), calendar: Calendar = .current,
                           in context: ModelContext) -> Entry? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let parsed = CaptureParser.parse(trimmed, now: now, calendar: calendar)
        // A note linked .to would never be waiting, so to: always captures a task.
        let finalKind: EntryKind =
            linkedTo?.link == .about ? .note
            : (parsed.to != nil || linkedTo?.link == .to) ? .task
            : kind
        let entry = Entry(
            text: parsed.text, kind: finalKind, scope: parsed.scope ?? scope, createdAt: now,
            showOn: calendar.isDate(day, inSameDayAs: now) ? nil : day,
            dueOn: parsed.dueOn, from: parsed.from, tags: parsed.tags, calendar: calendar
        )
        context.insert(entry)
        if let linkedTo {
            if linkedTo.link == .to {
                Review.delegate(entry, to: linkedTo.person, now: now)
            } else {
                entry.person = linkedTo.person
                entry.link = linkedTo.link
            }
        } else if let to = parsed.to, let person = try? PeopleDirectory.findOrCreate(to, in: context) {
            Review.delegate(entry, to: person, now: now)   // to: wins; from text stays on the entry
        } else if let from = parsed.from, let person = try? PeopleDirectory.findOrCreate(from, in: context) {
            entry.person = person
            entry.link = .from
        }
        if finalKind == .task {
            entry.isPriority = parsed.isPriority
            entry.setRepeat(parsed.repeatRule, calendar: calendar)
        }
        return entry
    }

    /// One entry per non-blank line, list markers stripped. Does not save.
    @discardableResult
    public static func addLines(_ text: String, kind: EntryKind = .task, scope: EntryScope, day: Date,
                                linkedTo: Link? = nil, now: Date = Date(), calendar: Calendar = .current,
                                in context: ModelContext) -> [Entry] {
        text.split(whereSeparator: \.isNewline).compactMap {
            add(String(stripListMarker($0.trimmingCharacters(in: .whitespaces)[...])), kind: kind, scope: scope,
                day: day, linkedTo: linkedTo, now: now, calendar: calendar, in: context)
        }
    }

    /// Drops one leading `-`, `*`, `•`, `–`, `[ ]`, `[x]` or `1.` / `1)` plus its whitespace, only when whitespace follows.
    public static func stripListMarker(_ line: Substring) -> Substring {
        var rest = line
        for m in ["[ ]", "[x]", "[X]", "-", "*", "•", "–"] where rest.hasPrefix(m) {
            rest = rest.dropFirst(m.count)
            let stripped = strip(rest, original: line)
            // A bullet may be followed by a Markdown checkbox ("- [ ] Call Sam").
            if m.count == 1, stripped.count < line.count {
                for box in ["[ ]", "[x]", "[X]"] where stripped.hasPrefix(box) {
                    return strip(stripped.dropFirst(3), original: stripped)
                }
            }
            return stripped
        }
        let digits = rest.prefix(while: { $0.isASCII && $0.isNumber })
        if !digits.isEmpty, let c = rest.dropFirst(digits.count).first, c == "." || c == ")" {
            return strip(rest.dropFirst(digits.count + 1), original: line)
        }
        return line
    }

    private static func strip(_ rest: Substring, original: Substring) -> Substring {
        guard let c = rest.first else { return rest }   // marker alone: nothing left
        guard c.isWhitespace else { return original }
        return rest.drop(while: \.isWhitespace)
    }
}
