import Foundation
import SwiftData

/// Finding, creating and tidying people. Names are matched loosely:
/// case, extra spaces, underscores (`to:priya_s`) and diacritics don't matter.
public enum PeopleDirectory {

    public static func normalize(_ name: String) -> String {
        words(name).joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// How a typed name is stored: underscores become spaces, each word starts uppercase.
    public static func displayName(_ typed: String) -> String {
        words(typed).map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }

    /// Index of the person `typed` refers to: exact match first, else the only prefix match.
    public static func match(_ typed: String, in names: [String]) -> Int? {
        let key = normalize(typed)
        guard !key.isEmpty else { return nil }
        let keys = names.map(normalize)
        if let exact = keys.firstIndex(of: key) { return exact }
        let prefixed = keys.indices.filter { keys[$0].hasPrefix(key) }
        return prefixed.count == 1 ? prefixed[0] : nil
    }

    public static func findOrCreate(_ typed: String, in context: ModelContext) throws -> Person {
        var people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        return findOrCreate(typed, among: &people, in: context)
    }

    /// Moves `duplicate`'s entries onto `keeper`, fills details the keeper lacks, deletes the duplicate.
    public static func merge(_ duplicate: Person, into keeper: Person, in context: ModelContext) {
        let moved = duplicate.entries ?? []
        for entry in moved { entry.person = keeper }
        if keeper.team == nil { keeper.team = duplicate.team }
        if keeper.role == .other { keeper.role = duplicate.role }
        keeper.isSorted = keeper.isSorted || duplicate.isSorted
        context.delete(duplicate)
    }

    /// Combines people whose names match (e.g. created offline on two devices). Oldest wins.
    public static func mergeDuplicates(in context: ModelContext) throws {
        let people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        var keepers: [String: Person] = [:]
        for person in people {
            let key = normalize(person.name)
            if let keeper = keepers[key] {
                merge(person, into: keeper, in: context)
            } else {
                keepers[key] = person
            }
        }
    }

    /// Links entries captured before people existed (`from:` text only). Safe to run repeatedly.
    public static func backfillFromText(in context: ModelContext) throws {
        var people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        for entry in try context.fetch(FetchDescriptor<Entry>()) where entry.person == nil && entry.linkRaw == nil {
            guard let from = entry.from, !words(from).isEmpty else { continue }
            entry.person = findOrCreate(from, among: &people, in: context)
            entry.link = .from
        }
    }

    /// Deletes a person; their entries stay as R's own (waiting items become R's tasks again).
    /// `from` text is cleared too, so backfill can't recreate the person.
    public static func delete(_ person: Person, in context: ModelContext) {
        for entry in person.entries ?? [] {
            entry.link = nil
            entry.from = nil
        }
        context.delete(person)
    }

    /// Run at launch and whenever the app comes to the foreground.
    public static func tidy(in context: ModelContext) throws {
        try backfillFromText(in: context)
        try mergeDuplicates(in: context)
        try context.save()
    }

    /// The `from:` / `to:` token being typed at the end of `text`, if any.
    public static func completionToken(in text: String) -> (keyword: String, partial: String)? {
        guard let last = text.split(separator: " ", omittingEmptySubsequences: false).last else { return nil }
        for keyword in ["from:", "to:"] where last.lowercased().hasPrefix(keyword) {
            return (keyword, String(last.dropFirst(keyword.count)))
        }
        return nil
    }

    /// Indexes of names starting with `partial` (all names when empty), up to `limit`.
    public static func completions(for partial: String, in names: [String], limit: Int = 5) -> [Int] {
        let key = normalize(partial)
        return Array(names.indices.filter { key.isEmpty || normalize(names[$0]).hasPrefix(key) }.prefix(limit))
    }

    // MARK: Private

    private static func words(_ s: String) -> [String] {
        s.replacingOccurrences(of: "_", with: " ").split(whereSeparator: \.isWhitespace).map(String.init)
    }

    private static func findOrCreate(_ typed: String, among people: inout [Person], in context: ModelContext) -> Person {
        if let i = match(typed, in: people.map(\.name)) { return people[i] }
        let person = Person(name: displayName(typed))
        context.insert(person)
        people.append(person)
        return person
    }
}
