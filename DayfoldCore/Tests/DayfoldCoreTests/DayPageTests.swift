import Foundation
import Testing
@testable import DayfoldCore

/// Plain value used to test the rules without SwiftData.
struct FakeItem: DayPageItem {
    var createdAt: Date
    var kind: EntryKind = .task
    var status: EntryStatus = .open
    var closedAt: Date? = nil
    var showOn: Date
    var link: PersonLink? = nil
    var delegatedAt: Date? = nil
    var nudgedAt: Date? = nil
}

private let cal: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
    return c
}()

private func day(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 9) -> Date {
    cal.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
}

private func task(on date: Date, status: EntryStatus = .open, closedAt: Date? = nil, showOn: Date? = nil) -> FakeItem {
    FakeItem(createdAt: date, kind: .task, status: status, closedAt: closedAt, showOn: cal.startOfDay(for: showOn ?? date))
}

@Suite("Day page rules")
struct DayPageTests {

    let mon = day(2026, 10, 19)
    let tue = day(2026, 10, 20)
    let wed = day(2026, 10, 21)

    @Test("An open task carries forward to every later day")
    func openTaskCarriesForward() {
        let t = task(on: mon)
        #expect(DayPage.contains(t, on: mon, calendar: cal))
        #expect(DayPage.contains(t, on: tue, calendar: cal))
        #expect(DayPage.contains(t, on: wed, calendar: cal))
    }

    @Test("A task does not appear before it was captured")
    func taskNotVisibleBeforeCapture() {
        let t = task(on: tue)
        #expect(!DayPage.contains(t, on: mon, calendar: cal))
    }

    @Test("A task closed on Tuesday appears Mon–Tue but not Wed")
    func closedTaskStopsCarrying() {
        let t = task(on: mon, status: .done, closedAt: day(2026, 10, 20, 18))
        #expect(DayPage.contains(t, on: mon, calendar: cal) == false, "closed tasks show only on their closing day")
        #expect(DayPage.contains(t, on: tue, calendar: cal))
        #expect(!DayPage.contains(t, on: wed, calendar: cal))
    }

    @Test("A pushed task stays hidden until its showOn day")
    func pushedTaskHiddenUntilShowOn() {
        let t = task(on: mon, showOn: wed)
        #expect(!DayPage.contains(t, on: mon, calendar: cal))
        #expect(!DayPage.contains(t, on: tue, calendar: cal))
        #expect(DayPage.contains(t, on: wed, calendar: cal))
    }

    @Test("Notes belong to their day only")
    func notesNeverCarry() {
        let n = FakeItem(createdAt: mon, kind: .note, showOn: cal.startOfDay(for: mon))
        #expect(DayPage.contains(n, on: mon, calendar: cal))
        #expect(!DayPage.contains(n, on: tue, calendar: cal))
    }

    @Test("Age counts whole days since capture")
    func ageInDays() {
        let t = task(on: mon)
        #expect(DayPage.age(of: t, on: mon, calendar: cal) == 0)
        #expect(DayPage.age(of: t, on: wed, calendar: cal) == 2)
    }

    @Test("Dropped tasks behave like done ones")
    func droppedTaskIsClosed() {
        let t = task(on: mon, status: .dropped, closedAt: day(2026, 10, 19, 18))
        #expect(DayPage.contains(t, on: mon, calendar: cal))
        #expect(!DayPage.contains(t, on: tue, calendar: cal))
    }
}

@Suite("Review rules")
struct ReviewTests {

    let mon = day(2026, 10, 19)
    let tue = day(2026, 10, 20)

    @Test("Pending review = active tasks visible today, not notes, not future tasks")
    func pendingFilters() {
        let items = [
            task(on: mon),                                   // yes
            task(on: mon, status: .inProgress),              // yes
            task(on: mon, status: .done, closedAt: mon),     // no
            task(on: mon, showOn: tue),                      // no – future
            FakeItem(createdAt: mon, kind: .note, showOn: cal.startOfDay(for: mon)), // no
        ]
        #expect(Review.pending(items, on: mon, calendar: cal).count == 2)
    }

    @Test("Review actions update an Entry")
    func applyActions() {
        let now = day(2026, 10, 19, 18)

        let e1 = Entry(text: "a", createdAt: mon, calendar: cal)
        Review.apply(.done, to: e1, now: now, calendar: cal)
        #expect(e1.status == .done && e1.closedAt == now)

        let e2 = Entry(text: "b", createdAt: mon, calendar: cal)
        Review.apply(.stillGoing, to: e2, now: now, calendar: cal)
        #expect(e2.status == .inProgress && e2.closedAt == nil)

        let e3 = Entry(text: "c", createdAt: mon, calendar: cal)
        Review.apply(.push(to: tue), to: e3, now: now, calendar: cal)
        #expect(e3.showOn == cal.startOfDay(for: tue))
        #expect(e3.status == .open)

        let e4 = Entry(text: "d", createdAt: mon, calendar: cal)
        Review.apply(.drop, to: e4, now: now, calendar: cal)
        #expect(e4.status == .dropped && e4.closedAt == now)

        Review.reopen(e4)
        #expect(e4.status == .open && e4.closedAt == nil)
    }
}
