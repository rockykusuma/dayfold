import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

private let cal: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
    return c
}()

private func day(_ d: Int, _ h: Int = 9) -> Date {
    cal.date(from: DateComponents(year: 2026, month: 10, day: d, hour: h))!   // 19 = Monday
}

private func waiting(created: Date, delegated: Date? = nil, nudged: Date? = nil) -> FakeItem {
    FakeItem(createdAt: created, showOn: cal.startOfDay(for: created),
             link: .to, delegatedAt: delegated, nudgedAt: nudged)
}

@Suite("Waiting items in Review")
struct WaitingReviewTests {

    @Test("Own pending review excludes waiting items")
    func pendingExcludesWaiting() {
        let own = FakeItem(createdAt: day(19), showOn: cal.startOfDay(for: day(19)))
        let theirs = waiting(created: day(19), delegated: day(19))
        #expect(Review.pending([own, theirs], on: day(19), calendar: cal).count == 1)
    }

    @Test("Stale is whole calendar days, inclusive: Mon 18:00 → Thu 09:00 is 3 days")
    func staleBoundary() {
        let w = waiting(created: day(19, 10), delegated: day(19, 18))
        #expect(Review.waitingDays(w, on: day(22, 9), calendar: cal) == 3)
        #expect(Review.staleWaiting([w], on: day(22, 9), after: 3, calendar: cal).count == 1)
        #expect(Review.staleWaiting([w], on: day(21, 9), after: 3, calendar: cal).isEmpty)
    }

    @Test("Nudging restarts the clock")
    func nudgeResets() {
        let w = waiting(created: day(19), delegated: day(19), nudged: day(21))
        #expect(Review.waitingDays(w, on: day(22), calendar: cal) == 1)
        #expect(Review.staleWaiting([w], on: day(22), after: 3, calendar: cal).isEmpty)
    }

    @Test("Queue is own tasks first, then stale waiting, oldest wait first")
    func queueOrder() {
        let own = FakeItem(createdAt: day(22), showOn: cal.startOfDay(for: day(22)))
        let older = waiting(created: day(12), delegated: day(12))
        let newer = waiting(created: day(17), delegated: day(17))
        let q = Review.queue([newer, own, older], on: day(22), nudgeAfter: 3, calendar: cal)
        #expect(q.count == 3)
        #expect(q[0].isWaiting == false)
        #expect(q[1].createdAt == day(12) && q[2].createdAt == day(17))
    }
}

@Suite("Delegate and nudge actions") @MainActor
struct DelegateActionTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test("Delegate links the person, marks waiting, keeps who asked as text")
    func delegateKeepsAskedBy() {
        let priya = Person(name: "Priya"), arjun = Person(name: "Arjun")
        let e = Entry(text: "Q4 numbers")
        [priya, arjun].forEach(context.insert); context.insert(e)
        e.person = priya; e.link = .from
        e.status = .inProgress

        let now = day(20, 11)
        Review.delegate(e, to: arjun, now: now)
        #expect(e.person?.id == arjun.id)
        #expect(e.link == .to && e.isWaiting)
        #expect(e.delegatedAt == now && e.nudgedAt == nil)
        #expect(e.status == .open)
        #expect(e.from == "Priya")
    }

    @Test func nudgedSetsTimestampOnly() {
        let e = Entry(text: "x")
        context.insert(e)
        Review.apply(.nudged, to: e, now: day(21), calendar: cal)
        #expect(e.nudgedAt == day(21) && e.status == .open && e.closedAt == nil)
    }
}
