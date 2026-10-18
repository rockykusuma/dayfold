import Foundation

public struct TagCount: Identifiable, Equatable, Sendable {
    public let tag: String
    public let count: Int
    public var id: String { Tags.key(tag) }
}

public enum Tags {

    /// `#Hiring`, `hiring,` and `híring` are the same tag.
    public static func key(_ tag: String) -> String {
        PeopleDirectory.normalize(clean(tag))
    }

    /// Each tag once per entry, shown as spelled on the newest entry; most used first, then by name.
    public static func all(_ entries: [Entry]) -> [TagCount] {
        var spelling: [String: String] = [:]
        var counts: [String: Int] = [:]
        for entry in entries.sorted(by: { $0.createdAt > $1.createdAt }) {
            for tag in Set(entry.tags.map(key)) { counts[tag, default: 0] += 1 }
            for tag in entry.tags where spelling[key(tag)] == nil && !key(tag).isEmpty { spelling[key(tag)] = clean(tag) }
        }
        return counts.compactMap { k, n in spelling[k].map { TagCount(tag: $0, count: n) } }
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.id < $1.id }
    }

    /// Tags as shown on a row: cleaned, user's spelling kept, empty ones dropped, one per key, input order.
    public static func display(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        return tags.map(clean).filter { !key($0).isEmpty && seen.insert(key($0)).inserted }
    }

    /// The editor's free-text field: split on spaces and commas, first spelling of each tag wins.
    public static func parse(_ text: String) -> [String] {
        var seen = Set<String>()
        return text.split(whereSeparator: { $0 == "," || $0.isWhitespace })
            .map { String($0.drop(while: { $0 == "#" })) }
            .filter { !$0.isEmpty && seen.insert(key($0)).inserted }
    }

    private static func clean(_ tag: String) -> String {
        tag.drop(while: { $0 == "#" }).trimmingTrailingPunctuation
    }
}
