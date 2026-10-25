import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Search") @MainActor
struct SearchTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    /// a: starred hiring task from Meera · b: done café task · c: waiting on Arjun
    /// d: note · e: weekly task with checklist, from-text "Priya"
    private func fixtures() -> [Entry] {
        let meera = Person(name: "Meera"), arjun = Person(name: "Arjun")
        [meera, arjun].forEach(context.insert)
        let a = Entry(text: "Send Q4 hiring plan", createdAt: at(2026,10,19,9), tags: ["Hiring"], calendar: ist)
        let b = Entry(text: "Café budget review", createdAt: at(2026,10,20,10), calendar: ist)
        let c = Entry(text: "Q4 capacity numbers", createdAt: at(2026,10,18,9), calendar: ist)
        let d = Entry(text: "1:1 with Sam", kind: .note, createdAt: at(2026,10,20,12), calendar: ist)
        let e = Entry(text: "Weekly report", createdAt: at(2026,10,17,9), from: "Priya", calendar: ist)
        [a, b, c, d, e].forEach(context.insert)
        a.person = meera; a.link = .from; a.isPriority = true
        b.status = .done; b.closedAt = at(2026,10,20,11)
        Review.delegate(c, to: arjun, now: at(2026,10,18,9))
        e.repeatRaw = "weekly"
        let item = ChecklistItem(text: "Collect metrics"); context.insert(item); item.entry = e
        return [a, b, c, d, e]
    }
    private func texts(_ q: String, _ all: [Entry]) -> [String] { Search.results(all, query: q).map(\.text) }

    @Test func tokensAreANDedAndEmptyIsNothing() {
        let all = fixtures()
        #expect(texts("  ", all).isEmpty)
        #expect(texts("q4", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])
        #expect(texts("q4 hiring", all) == ["Send Q4 hiring plan"])
        #expect(texts("q4 #", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])   // bare sigil ignored
    }

    @Test func tagsAndPeople() {
        let all = fixtures()
        #expect(texts("#hiring", all) == ["Send Q4 hiring plan"])
        #expect(texts("#hir", all).isEmpty)                      // tags match exactly
        #expect(texts("@mee", all) == ["Send Q4 hiring plan"])
        #expect(texts("@arj", all) == ["Q4 capacity numbers"])
        #expect(texts("@priya", all) == ["Weekly report"])       // from text
        #expect(texts("@sam", all).isEmpty)                      // name in text only
    }

    @Test func stateFilters() {
        let all = fixtures()
        #expect(texts("is:open", all) == ["Send Q4 hiring plan", "Q4 capacity numbers", "Weekly report"])
        #expect(texts("is:done", all) == ["Café budget review"])
        #expect(texts("is:waiting", all) == ["Q4 capacity numbers"])
        #expect(texts("is:priority", all) == ["Send Q4 hiring plan"])
        #expect(texts("is:repeating", all) == ["Weekly report"])
        #expect(texts("is:note", all) == ["1:1 with Sam"])
        #expect(texts("is:open q4", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])
    }

    @Test func diacriticsAndChecklistText() {
        let all = fixtures()
        #expect(texts("cafe", all) == ["Café budget review"])
        #expect(texts("CAFÉ", all) == ["Café budget review"])
        #expect(texts("metrics", all) == ["Weekly report"])
    }

    @Test("Open tasks first, then newest first; groups by capture day, newest day first")
    func orderingAndGroups() {
        let all = fixtures()
        let r = Search.results(all, query: "a")
        #expect(r.map(\.text) == ["Send Q4 hiring plan", "Q4 capacity numbers", "Weekly report",
                                  "1:1 with Sam", "Café budget review"])
        let groups = Search.dayGroups(r, calendar: ist)
        #expect(groups.map(\.day) == [at(2026,10,20), at(2026,10,19), at(2026,10,18), at(2026,10,17)])
        #expect(groups[0].entries.map(\.text) == ["1:1 with Sam", "Café budget review"])
    }

    @Test func completionToken() {
        #expect(Search.completionToken(in: "q4 #hi")! == ("#", "hi"))
        #expect(Search.completionToken(in: "@")! == ("@", ""))
        #expect(Search.completionToken(in: "q4 #hiring ") == nil)
        #expect(Search.completionToken(in: "plain") == nil)
    }

    @Test func replacingTrailingToken() {
        #expect(Search.replacingTrailingToken(in: "meet #hi", with: "#hiring") == "meet #hiring ")
        #expect(Search.replacingTrailingToken(in: "@pri", with: "@Priya_Sharma") == "@Priya_Sharma ")
        #expect(Search.replacingTrailingToken(in: "", with: "#ops") == "#ops ")
        #expect(Search.replacingTrailingToken(in: "x ", with: "#ops") == "x #ops ")
    }

    @Test("Searching 5,000 entries returns the right hits")
    func largeStore() {
        let big = (0..<5_000).map { i in
            Entry(text: "Entry \(i) about the quarterly plan", createdAt: Date(timeIntervalSince1970: Double(i)), tags: ["t\(i % 50)"])
        }
        var hits: [Entry] = []
        let elapsed = ContinuousClock().measure { hits = Search.results(big, query: "#t7 quarterly") }
        #expect(hits.count == 100)
        #expect(elapsed < .seconds(5))   // lenient: Debug builds are slow
    }
}

extension SearchTests {
    @Test func journalMatchesWords() {
        let e = JournalEntry(date: at(2026,10,20), title: "Offsite", text: "Booked the venue in Goa")
        #expect(Search.journal([e], query: "venue goa").count == 1)
        #expect(Search.journal([e], query: "venue paris").isEmpty)
        #expect(Search.journal([e], query: "Gõa").count == 1)
    }

    @Test func journalIgnoresTaskTokens() {
        let e = JournalEntry(date: at(2026,10,20), title: "Offsite", text: "venue #hiring")
        #expect(Search.journal([e], query: "#hiring").isEmpty)
        #expect(Search.journal([e], query: "@meera venue").isEmpty)
        #expect(Search.journal([e], query: "is:open").isEmpty)
        #expect(Search.journal([e], query: "").isEmpty)
    }

    @Test func journalBareTokenExcluded() {
        let e = JournalEntry(date: at(2026,10,20), title: "Offsite", text: "venue")
        #expect(Search.journal([e], query: "venue #").isEmpty)
        #expect(Search.journal([e], query: "venue @").isEmpty)
        #expect(Search.journal([e], query: "venue is:").isEmpty)
        #expect(Search.journal([e], query: "venue IS:nope").isEmpty)
        #expect(Search.journal([e], query: "venue").count == 1)
    }

    @Test func journalOrder() {
        let old = JournalEntry(date: at(2026,10,1), text: "trip"), new = JournalEntry(date: at(2026,10,9), text: "trip")
        #expect(Search.journal([old, new], query: "trip").map(\.date) == [at(2026,10,9), at(2026,10,1)])
    }
}

extension SearchTests {
    @Test func pagesMatchWords() {
        let p = NotePage(title: "Release process", body: "Tag the build in Xcode")
        #expect(Search.pages([p], query: "release xcode").count == 1)
        #expect(Search.pages([p], query: "release android").isEmpty)
        #expect(Search.pages([p], query: "").isEmpty)
    }

    @Test func pagesTitleFirst() {
        let title = NotePage(title: "Xcode", body: "", updatedAt: at(2026,10,1))
        let body = NotePage(title: "Other", body: "use xcode", updatedAt: at(2026,10,9))
        #expect(Search.pages([body, title], query: "xcode").map(\.title) == ["Xcode", "Other"])
    }

    @Test func pagesIgnoreTaskTokens() {
        let p = NotePage(title: "x", body: "#x @a is:open")
        for q in ["#x", "@a", "is:open", "x #"] { #expect(Search.pages([p], query: q).isEmpty) }
    }
}
