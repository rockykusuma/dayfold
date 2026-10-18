import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Person page") @MainActor
struct PersonPageTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func entry(_ text: String, _ kind: EntryKind = .task, link: PersonLink, for p: Person, at t: TimeInterval) -> Entry {
        let e = Entry(text: text, kind: kind, createdAt: Date(timeIntervalSince1970: t))
        context.insert(e)
        e.person = p
        e.link = link
        return e
    }

    @Test("Owed, waiting and notes are separated and ordered")
    func sections() {
        let p = Person(name: "Priya"); context.insert(p)
        _ = entry("owe-new", link: .from, for: p, at: 200)
        _ = entry("owe-old", link: .from, for: p, at: 100)
        let done = entry("owe-done", link: .from, for: p, at: 50); done.status = .done
        _ = entry("wait", link: .to, for: p, at: 150)
        _ = entry("note-old", .note, link: .about, for: p, at: 10)
        _ = entry("note-new", .note, link: .about, for: p, at: 300)

        #expect(p.owed.map(\.text) == ["owe-old", "owe-new"])
        #expect(p.waiting.map(\.text) == ["wait"])
        #expect(p.notes.map(\.text) == ["note-new", "note-old"])
    }

    @Test("All waiting groups people with waiting items, oldest wait first")
    func allWaiting() {
        let a = Person(name: "Arjun"), b = Person(name: "Bea"), c = Person(name: "Cy")
        [a, b, c].forEach(context.insert)
        let day0 = Date(timeIntervalSince1970: 1_800_000_000)
        let e1 = entry("a1", link: .to, for: a, at: 0); e1.delegatedAt = day0.addingTimeInterval(-2 * 86_400)
        let e2 = entry("b1", link: .to, for: b, at: 0); e2.delegatedAt = day0.addingTimeInterval(-6 * 86_400)
        _ = entry("c-owe", link: .from, for: c, at: 0)

        let groups = PersonPage.allWaiting([a, b, c], on: day0)
        #expect(groups.map(\.person.name) == ["Bea", "Arjun"])
        #expect(groups[0].oldestDays == 6)
        #expect(a.oldestWaitingDays(on: day0) == 2)
        #expect(c.oldestWaitingDays(on: day0) == nil)
    }
}
