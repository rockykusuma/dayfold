import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Journal suggestions") @MainActor
struct JournalSuggestionsTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    let day = at(2026, 10, 22, 18)

    func task(_ text: String, created: Date = at(2026, 10, 22, 9)) -> Entry {
        let e = Entry(text: text, createdAt: created, calendar: ist)
        context.insert(e)
        return e
    }
    func finish(_ e: Entry, _ when: Date, for p: Person? = nil) {
        if let p { e.person = p; e.link = .from }
        Review.apply(.done, to: e, now: when, calendar: ist)
    }
    func person(_ n: String) -> Person { let p = Person(name: n); context.insert(p); return p }
    func make(_ tasks: [Entry]) -> [JournalSuggestion] { JournalSuggestions.make(tasks: tasks, day: day, calendar: ist) }

    @Test func finishedPlural() {
        let a = task("Early"), b = task("Send deck")
        finish(a, at(2026, 10, 22, 10)); finish(b, at(2026, 10, 22, 15), for: person("Meera"))
        let s = make([a, b])[0]
        #expect(s.title == "You finished 2 things")
        #expect(s.detail == "Including “Send deck” for Meera")
        #expect(s.kind == .fromYourDay)
    }

    @Test func finishedSingularNoPerson() {
        let a = task("text"); finish(a, at(2026, 10, 22, 10))
        let s = make([a])[0]
        #expect(s.title == "You finished 1 thing")
        #expect(s.detail == "Including “text”")
    }

    @Test func waitingUsesName() {
        let a = task("Contract", created: at(2026, 10, 1, 9))
        Review.delegate(a, to: person("Ravi"), now: at(2026, 10, 16, 9))
        let s = make([a])[0]
        #expect(s.title == "Ravi has owed you this for 6d")
        #expect(s.detail == "“Contract”")
    }

    @Test func openLong() {
        let s = make([task("Report", created: at(2026, 10, 18, 9))])[0]
        #expect(s.title == "Open for 4d")
        #expect(s.detail == "“Report”")
    }

    @Test func askedToday() {
        let a = task("Review PR"); a.person = person("Priya"); a.link = .from
        let s = make([a])[0]
        #expect(s.title == "Priya asked you today")
        #expect(s.detail == "“Review PR”")
    }

    @Test func capAtThree() {
        let d = task("Done one"); finish(d, at(2026, 10, 22, 10))
        let w = task("Wait", created: at(2026, 10, 1, 9)); Review.delegate(w, to: person("Ravi"), now: at(2026, 10, 16, 9))
        let o = task("Old", created: at(2026, 10, 18, 9))
        let a = task("Asked"); a.person = person("Priya"); a.link = .from
        let all = make([d, w, o, a])
        #expect(all.count == 6)
        #expect(all.prefix(3).map(\.title) == ["You finished 1 thing", "Ravi has owed you this for 6d", "Open for 4d"])
        #expect(all.suffix(3).allSatisfy { $0.kind == .prompt })
    }

    @Test func promptsOnlyOnEmptyDay() {
        let s = make([])
        #expect(s.count == 3 && s.allSatisfy { $0.kind == .prompt })
        #expect(s.map(\.title) == ["What's on your mind for tomorrow?", "Who helped you today?", "What did you learn today?"])
        #expect(s.map(\.id) == s.map(\.title))
    }
}
