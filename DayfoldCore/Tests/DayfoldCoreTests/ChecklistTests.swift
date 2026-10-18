import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Checklist") @MainActor
struct ChecklistTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func entry(_ items: [String]) -> Entry {
        let e = Entry(text: "Ship"); context.insert(e)
        items.forEach { Checklist.add($0, to: e, in: context) }
        return e
    }
    private func texts(_ e: Entry) -> [String] { e.sortedChecklist.map(\.text) }

    @Test("Add appends in order, trims, ignores blanks")
    func add() {
        let e = entry([])
        #expect(e.checklistProgress == nil)
        Checklist.add(" draft ", to: e, in: context); Checklist.add("review", to: e, in: context)
        #expect(Checklist.add("   ", to: e, in: context) == nil)
        #expect(texts(e) == ["draft", "review"] && e.sortedChecklist.map(\.order) == [0, 1])
    }

    @Test("Progress counts ticks; ticking everything doesn't close the task")
    func progress() {
        let e = entry(["a", "b"])
        e.sortedChecklist[0].isDone = true
        #expect(e.checklistProgress?.done == 1 && e.checklistProgress?.total == 2)
        e.sortedChecklist[1].isDone = true
        #expect(e.checklistProgress?.done == 2 && e.status == .open)
    }

    @Test("Moving one item rewrites only that item's order")
    func moveMidpoint() {
        let e = entry(["x", "y", "z"])
        Checklist.move(in: e, from: [2], to: 1)
        #expect(texts(e) == ["x", "z", "y"] && e.sortedChecklist.map(\.order) == [0, 0.5, 1])
        Checklist.move(in: e, from: [0], to: 3)
        #expect(texts(e) == ["z", "y", "x"] && e.sortedChecklist[2].order == 2)
        Checklist.move(in: e, from: [2], to: 0)
        #expect(texts(e) == ["x", "z", "y"] && e.sortedChecklist[0].order == -0.5)
    }

    @Test("Items appended on two devices with equal order stay stable and can be reordered")
    func tiedOrders() {
        let e = Entry(text: "Ship"); context.insert(e)
        for (t, o, s) in [("p", 0.0, 0.0), ("q", 1, 10), ("r", 1, 20)] {
            let i = ChecklistItem(text: t, order: o, createdAt: Date(timeIntervalSince1970: s))
            context.insert(i); i.entry = e
        }
        #expect(texts(e) == ["p", "q", "r"])
        Checklist.move(in: e, from: [0], to: 2)
        #expect(texts(e) == ["q", "p", "r"] && e.sortedChecklist.map(\.order) == [0, 1, 2])
    }
}
