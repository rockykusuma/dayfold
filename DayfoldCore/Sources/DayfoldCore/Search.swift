import Foundation

public struct SearchDayGroup: Identifiable {
    public let day: Date
    public let entries: [Entry]
    public var id: Date { day }
}

/// Find across every entry. Space-separated tokens are ANDed:
/// `#tag` (exact), `@person` (name or `from`, prefix), `is:open|done|waiting|priority|repeating|note`,
/// anything else is a case- and diacritic-insensitive substring of the entry's text, tags, people and checklist.
public enum Search {

    private enum Token {
        case tag(String)
        case person(String)
        case state(String)
        case text(String)
    }

    private static let states: Set<String> = ["open", "done", "waiting", "priority", "repeating", "note"]

    public static func matches(_ entry: Entry, query: String) -> Bool {
        let tokens = parse(query)
        return !tokens.isEmpty && matches(entry, tokens)
    }

    /// Open tasks first, then newest first. Empty query finds nothing.
    public static func results(_ entries: [Entry], query: String) -> [Entry] {
        let tokens = parse(query)
        guard !tokens.isEmpty else { return [] }
        func isOpenTask(_ e: Entry) -> Bool { e.kind == .task && e.status.isActive }
        return entries.enumerated()
            .filter { matches($0.element, tokens) }
            .sorted { a, b in
                let (x, y) = (a.element, b.element)
                if isOpenTask(x) != isOpenTask(y) { return isOpenTask(x) }
                if x.createdAt != y.createdAt { return x.createdAt > y.createdAt }
                return a.offset < b.offset
            }
            .map(\.element)
    }

    /// Journal entries whose title or text contain every plain word (AND, case/diacritic-insensitive), newest first.
    /// `#`, `@` and `is:` tokens are about tasks, so they find nothing here.
    public static func journal(_ entries: [JournalEntry], query: String) -> [JournalEntry] {
        let tokens = parse(query)
        let keys = tokens.compactMap { if case .text(let k) = $0 { k } else { nil } }
        guard !keys.isEmpty, keys.count == tokens.count else { return [] }
        return entries
            .filter { e in
                let h = PeopleDirectory.normalize(e.title + " " + e.text)
                return keys.allSatisfy(h.contains)
            }
            .sorted { $0.date > $1.date }
    }

    /// By capture day, newest day first; order within a day is kept.
    public static func dayGroups(_ results: [Entry], calendar: Calendar = .current) -> [SearchDayGroup] {
        Dictionary(grouping: results) { calendar.startOfDay(for: $0.createdAt) }
            .map { SearchDayGroup(day: $0.key, entries: $0.value) }
            .sorted { $0.day > $1.day }
    }

    /// The `#tag` / `@person` being typed at the end of `query`, if any.
    public static func completionToken(in query: String) -> (sigil: Character, partial: String)? {
        guard let last = query.split(omittingEmptySubsequences: false, whereSeparator: \.isWhitespace).last,
              let sigil = last.first, sigil == "#" || sigil == "@" else { return nil }
        return (sigil, String(last.dropFirst()))
    }

    /// Swaps the token being typed for a chosen suggestion, plus a trailing space.
    public static func replacingTrailingToken(in query: String, with token: String) -> String {
        let parts = query.split(omittingEmptySubsequences: false, whereSeparator: \.isWhitespace)
        guard let last = parts.last, !last.isEmpty else { return query + token + " " }
        return query.dropLast(last.count) + token + " "
    }

    // MARK: Private

    private static func parse(_ query: String) -> [Token] {
        query.split(whereSeparator: \.isWhitespace).compactMap { raw in
            let word = String(raw)
            if word.hasPrefix("#") {
                let key = Tags.key(word)
                return key.isEmpty ? nil : .tag(key)
            }
            if word.hasPrefix("@") {
                let key = PeopleDirectory.normalize(String(word.dropFirst()))
                return key.isEmpty ? nil : .person(key)
            }
            if word.lowercased().hasPrefix("is:"), states.contains(word.dropFirst(3).lowercased()) {
                return .state(word.dropFirst(3).lowercased())
            }
            let key = PeopleDirectory.normalize(word)
            return key.isEmpty ? nil : .text(key)
        }
    }

    private static func matches(_ entry: Entry, _ tokens: [Token]) -> Bool {
        // ponytail: haystack built per call even when only tag/state tokens are used; cheap at thousands of entries.
        var haystack: String?
        for token in tokens {
            switch token {
            case .tag(let key):
                if !entry.tags.contains(where: { Tags.key($0) == key }) { return false }
            case .person(let key):
                let names = [entry.person?.name, entry.from].compactMap { $0 }
                if !names.contains(where: { PeopleDirectory.normalize($0).hasPrefix(key) }) { return false }
            case .state(let state):
                if !hasState(entry, state) { return false }
            case .text(let key):
                let h = haystack ?? {
                    let parts = [entry.text] + entry.tags + [entry.person?.name, entry.from].compactMap { $0 }
                        + (entry.checklist ?? []).map(\.text)
                    return PeopleDirectory.normalize(parts.joined(separator: " "))
                }()
                haystack = h
                if !h.contains(key) { return false }
            }
        }
        return true
    }

    private static func hasState(_ entry: Entry, _ state: String) -> Bool {
        switch state {
        case "open": entry.kind == .task && entry.status.isActive
        case "done": entry.status == .done
        case "waiting": entry.isWaiting
        case "priority": entry.isPriority
        case "repeating": entry.repeatRule != nil
        default: entry.kind == .note
        }
    }
}
