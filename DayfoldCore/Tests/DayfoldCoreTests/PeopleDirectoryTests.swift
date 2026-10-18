import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("People directory — names")
struct PeopleNameTests {
    @Test func normalizeIgnoresCaseSpacesUnderscoresAndDiacritics() {
        #expect(PeopleDirectory.normalize(" Priya ") == PeopleDirectory.normalize("PRIYA"))
        #expect(PeopleDirectory.normalize("priya_sharma") == PeopleDirectory.normalize("Priya  Sharma"))
        #expect(PeopleDirectory.normalize("jose") == PeopleDirectory.normalize("José"))
    }

    @Test func displayNameCapitalisesWordsAndKeepsTheRest() {
        #expect(PeopleDirectory.displayName("priya_sharma") == "Priya Sharma")
        #expect(PeopleDirectory.displayName("mcDonald") == "McDonald")
    }

    @Test func matchPrefersExactThenUniquePrefix() {
        let names = ["Priya Sharma", "Priya Nair", "Arjun", "José"]
        #expect(PeopleDirectory.match("arjun", in: names) == 2)
        #expect(PeopleDirectory.match("arj", in: names) == 2)
        #expect(PeopleDirectory.match("priya", in: names) == nil)          // ambiguous
        #expect(PeopleDirectory.match("priya_n", in: names) == 1)
        #expect(PeopleDirectory.match("jose", in: names) == 3)
        #expect(PeopleDirectory.match("", in: names) == nil)
    }

    @Test func completionTokenOnlyForTrailingFromOrTo() {
        #expect(PeopleDirectory.completionToken(in: "Ask for numbers to:ar")! == ("to:", "ar"))
        #expect(PeopleDirectory.completionToken(in: "x from:")! == ("from:", ""))
        #expect(PeopleDirectory.completionToken(in: "to:arjun done") == nil)
        #expect(PeopleDirectory.completionToken(in: "plain text") == nil)
    }

    @Test func completionsArePrefixMatchesUpToLimit() {
        let names = ["Priya Sharma", "Priya Nair", "Arjun", "Pat"]
        #expect(PeopleDirectory.completions(for: "pri", in: names) == [0, 1])
        #expect(PeopleDirectory.completions(for: "", in: names, limit: 2) == [0, 1])
    }
}

@Suite("People directory — store") @MainActor
struct PeopleStoreTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func people() throws -> [Person] {
        try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    @Test func findOrCreateReusesExisting() throws {
        let a = try PeopleDirectory.findOrCreate("priya", in: context)
        try context.save()
        let b = try PeopleDirectory.findOrCreate("Priya", in: context)
        #expect(a.id == b.id)
        #expect(try people().count == 1)
        #expect(a.name == "Priya")
    }

    @Test("Merge keeps the oldest, moves entries, fills missing details, and is idempotent")
    func mergeDuplicates() throws {
        let old = Person(name: "Priya", createdAt: Date(timeIntervalSince1970: 0))
        let dup = Person(name: "priya", role: .report, team: "Platform", createdAt: Date(timeIntervalSince1970: 100))
        let e = Entry(text: "x")
        [old, dup].forEach(context.insert); context.insert(e)
        e.person = dup; e.link = .from
        try context.save()

        try PeopleDirectory.mergeDuplicates(in: context)
        try context.save()
        let left = try people()
        #expect(left.count == 1)
        #expect(left[0].id == old.id)
        #expect(left[0].role == .report && left[0].team == "Platform")
        #expect(e.person?.id == old.id && e.link == .from)

        try PeopleDirectory.mergeDuplicates(in: context)
        #expect(try people().count == 1)
    }

    @Test("Merge keeps the keeper's own role and team when it has them")
    func mergeKeepsKeeperDetails() throws {
        let keeper = Person(name: "Sam", role: .peer, team: "Sync", createdAt: Date(timeIntervalSince1970: 0))
        let dup = Person(name: "sam", role: .report, team: "Platform", createdAt: Date(timeIntervalSince1970: 1))
        [keeper, dup].forEach(context.insert)
        PeopleDirectory.merge(dup, into: keeper, in: context)
        #expect(keeper.role == .peer && keeper.team == "Sync")
    }

    @Test("Backfill links legacy from: text once and ignores blanks")
    func backfill() throws {
        let a = Entry(text: "a", from: "priya")
        let b = Entry(text: "b", from: "Priya")
        let c = Entry(text: "c", from: "  ")
        [a, b, c].forEach(context.insert)
        try PeopleDirectory.backfillFromText(in: context)
        try PeopleDirectory.backfillFromText(in: context)
        try context.save()
        #expect(try people().count == 1)
        #expect(a.link == .from && b.person?.id == a.person?.id)
        #expect(c.person == nil)
    }

    @Test("Delete keeps entries, unlinks them, and backfill doesn't resurrect the person")
    func deleteUnlinks() throws {
        let p = Person(name: "Arjun")
        let waiting = Entry(text: "sync doc", from: "arjun")
        context.insert(p); context.insert(waiting)
        waiting.person = p; waiting.link = .to
        try context.save()

        PeopleDirectory.delete(p, in: context)
        try context.save()
        #expect(try people().isEmpty)
        #expect(waiting.person == nil && waiting.linkRaw == nil && waiting.isWaiting == false)
        try PeopleDirectory.backfillFromText(in: context)
        #expect(try people().isEmpty)
    }
}
