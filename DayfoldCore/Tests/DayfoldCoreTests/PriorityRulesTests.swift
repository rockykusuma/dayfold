import Testing
import Foundation
@testable import DayfoldCore

@Suite("Priority rules")
struct PriorityRulesTests {
    private func t(_ h: Int, priority: Bool = false, status: EntryStatus = .open,
                   kind: EntryKind = .task, link: PersonLink? = nil) -> FakeItem {
        FakeItem(createdAt: at(2026,10,19,h), kind: kind, status: status,
                 closedAt: status.isActive ? nil : at(2026,10,19,h), showOn: at(2026,10,19),
                 link: link, delegatedAt: link == .to ? at(2026,10,12) : nil, isPriority: priority)
    }

    @Test("Starred open tasks go to Priority; the timeline keeps capture order without them")
    func split() {
        let s = DayPage.prioritySplit([t(8), t(9, priority: true), t(10, priority: true, status: .done),
                                       t(11, priority: true, kind: .note), t(12, priority: true, status: .inProgress),
                                       t(13, priority: true, link: .to)])
        #expect(s.priority.map(\.createdAt) == [9, 12, 13].map { at(2026,10,19,$0) })
        #expect(s.timeline.map(\.createdAt) == [8, 10, 11].map { at(2026,10,19,$0) })
    }

    @Test("Review queue: starred own tasks first (stable), then the rest, then stale waiting")
    func queue() {
        let items = [t(9), t(10, priority: true), t(11), t(12, priority: true), t(13, priority: true, link: .to)]
        let q = Review.queue(items, on: at(2026,10,19,20), nudgeAfter: 3, calendar: ist)
        #expect(q.map(\.createdAt) == [10, 12, 9, 11, 13].map { at(2026,10,19,$0) })
    }
}
