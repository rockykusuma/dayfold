import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Week review") @MainActor
struct WeekReviewTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    let today = at(2026, 10, 23, 18)

    func person(_ name: String) -> Person { let p = Person(name: name); context.insert(p); return p }

    /// A done task closed at `closed`, optionally linked `.from` a person.
    @discardableResult
    func done(_ text: String, _ closed: Date, from p: Person? = nil) -> Entry {
        let e = Entry(text: text, createdAt: at(2026, 10, 1, 9), calendar: ist)
        context.insert(e)
        if let p { e.person = p; e.link = .from }
        Review.apply(.done, to: e, now: closed, calendar: ist)
        return e
    }

    func open(_ text: String, created: Date, showOn: Date? = nil) -> Entry {
        let e = Entry(text: text, createdAt: created, showOn: showOn, calendar: ist)
        context.insert(e)
        return e
    }

    func waiting(_ text: String, on p: Person, since: Date) -> Entry {
        let e = open(text, created: at(2026, 10, 1, 9))
        Review.delegate(e, to: p, now: since)
        return e
    }

    func week(_ entries: [Entry], notes: [DayNote] = [], containing d: Date? = nil, calendar: Calendar = ist) -> WeekReview {
        WeekReview(entries: entries, notes: notes, containing: d ?? today, today: today, calendar: calendar)
    }

    @Test func intervalFollowsFirstWeekday() {
        #expect(week([], containing: at(2026, 10, 19, 12)).interval.start == at(2026, 10, 18))
        var monday = ist
        monday.firstWeekday = 2
        #expect(week([], containing: at(2026, 10, 19, 12), calendar: monday).interval.start == at(2026, 10, 19))
    }

    @Test func doneGrouping() {
        let meera = person("Meera"), ravi = person("Ravi")
        let m2 = done("m2", at(2026, 10, 21, 10), from: meera)
        let m1 = done("m1", at(2026, 10, 19, 10), from: meera)
        let r = open("r", created: at(2026, 10, 1, 9))
        Review.delegate(r, to: ravi, now: at(2026, 10, 2))
        Review.apply(.done, to: r, now: at(2026, 10, 20), calendar: ist)
        let none = done("none", at(2026, 10, 22, 10))
        let note = Entry(text: "n", kind: .note, createdAt: at(2026, 10, 20), calendar: ist)
        context.insert(note)
        note.status = .done; note.closedAt = at(2026, 10, 20)
        let w = week([m2, m1, r, none, note])
        #expect(w.done.map { $0.person?.name } == ["Meera", "Ravi", nil])
        #expect(w.done[0].entries.map(\.text) == [m1.text, m2.text])
        #expect(w.done.flatMap(\.entries).contains { $0.kind == .note } == false)
        #expect(w.done[2].id == "none")
    }

    @Test func edgeOfWeek() {
        let late = done("late", at(2026, 10, 24, 23).addingTimeInterval(30 * 60))
        let early = done("early", at(2026, 10, 25, 0).addingTimeInterval(10 * 60))
        let this = week([late, early])
        #expect(this.done.flatMap(\.entries).map(\.text) == ["late"])
        let next = week([late, early], containing: at(2026, 10, 25, 12))
        #expect(next.done.flatMap(\.entries).map(\.text) == ["early"])
    }

    @Test func droppedCount() {
        let a = open("a", created: at(2026, 10, 1, 9)), b = open("b", created: at(2026, 10, 1, 9)), c = open("c", created: at(2026, 10, 1, 9))
        Review.apply(.drop, to: a, now: at(2026, 10, 19, 10), calendar: ist)
        Review.apply(.drop, to: b, now: at(2026, 10, 22, 10), calendar: ist)
        Review.apply(.drop, to: c, now: at(2026, 10, 12, 10), calendar: ist)
        #expect(week([a, b, c]).droppedCount == 2)
    }

    @Test func reopenedNotDone() {
        let e = done("x", at(2026, 10, 20, 10))
        Review.reopen(e)
        #expect(week([e]).done.isEmpty)
    }

    @Test func stuckRule() {
        let old = open("old", created: at(2026, 10, 19, 9))
        let older = open("older", created: at(2026, 10, 17, 9))
        let fresh = open("fresh", created: at(2026, 10, 22, 9))
        let w = waiting("w", on: person("Ravi"), since: at(2026, 10, 17))
        w.createdAt = at(2026, 10, 17, 9)
        let future = open("future", created: at(2026, 10, 19, 9), showOn: at(2026, 10, 26))
        #expect(week([old, fresh, w, future, older]).stuck.map(\.text) == ["older", "old"])
    }

    @Test func waitingGroups() {
        let ravi = person("Ravi"), meera = person("Meera")
        let r1 = waiting("r1", on: ravi, since: at(2026, 10, 20))
        let r2 = waiting("r2", on: ravi, since: at(2026, 10, 15))
        let m = waiting("m", on: meera, since: at(2026, 10, 17))
        let w = week([r1, m, r2])
        #expect(w.waiting.map { $0.person?.name } == ["Ravi", "Meera"])
        #expect(w.waiting[0].entries.map(\.text) == ["r2", "r1"])
    }

    @Test func pastWeekHasNoStuckOrWaiting() {
        let stuck = open("old", created: at(2026, 10, 12, 9))
        let w = waiting("w", on: person("Ravi"), since: at(2026, 10, 15))
        let past = week([stuck, w], containing: at(2026, 10, 12, 12))
        #expect(past.isCurrent == false)
        #expect(past.stuck.isEmpty && past.waiting.isEmpty)
        #expect(week([stuck, w]).isCurrent)
    }

    @Test func notesInWeek() {
        let notes = [DayNote(day: at(2026, 10, 21), text: "b", calendar: ist),
                     DayNote(day: at(2026, 10, 26), text: "c", calendar: ist),
                     DayNote(day: at(2026, 10, 19), text: "a", calendar: ist)]
        #expect(week([], notes: notes).notes.map(\.day) == [at(2026, 10, 19), at(2026, 10, 21)])
    }

    @Test func summaryTextExample() {
        let meera = person("Meera"), ravi = person("Ravi")
        let send = done("Send deck", at(2026, 10, 20, 10), from: meera)
        let budget = open("Budget numbers", created: at(2026, 10, 1, 9))
        Review.delegate(budget, to: ravi, now: at(2026, 10, 15))
        Review.apply(.done, to: budget, now: at(2026, 10, 21, 10), calendar: ist)
        let report = done("Weekly report", at(2026, 10, 22, 10))
        let bug = open("Fix login bug", created: at(2026, 10, 17, 9))
        let contract = waiting("Contract draft", on: ravi, since: at(2026, 10, 19, 9))
        let note = DayNote(day: at(2026, 10, 20), text: "private thoughts", calendar: ist)
        let text = week([send, budget, report, bug, contract], notes: [note]).summaryText(title: "Week of 19 Oct", calendar: ist)
        #expect(text == "Week of 19 Oct\nDone (3)\n• Send deck — Meera\n• Budget numbers — Ravi\n• Weekly report\nStill open (1)\n• Fix login bug (6d)\nWaiting on (1)\n• Ravi: Contract draft (4d)")
        #expect(!text.contains("private thoughts"))
    }

    @Test func summaryPastWeek() {
        let e = done("Ship it", at(2026, 10, 14, 10))
        let stuck = open("old", created: at(2026, 10, 1, 9))
        let text = week([e, stuck], containing: at(2026, 10, 14, 12)).summaryText(title: "Week of 11 Oct", calendar: ist)
        #expect(text == "Week of 11 Oct\nDone (1)\n• Ship it")
    }

    @Test func summarySkipsPersonal() {
        let home = done("Book dentist", at(2026, 10, 20, 10)); home.scope = .personal
        let work = done("Send deck", at(2026, 10, 21, 10))
        let stuck = open("Fix gutter", created: at(2026, 10, 17, 9)); stuck.scope = .personal
        let text = week([home, work, stuck]).summaryText(title: "Week of 19 Oct", calendar: ist)
        #expect(text == "Week of 19 Oct\nDone (1)\n• Send deck")
    }

    @Test func yearBoundary() {
        let a = done("a", at(2026, 12, 31, 10)), b = done("b", at(2027, 1, 2, 10))
        let w = week([a, b], containing: at(2026, 12, 29, 12))
        #expect(w.interval.start == at(2026, 12, 27))
        #expect(w.done.flatMap(\.entries).count == 2)
    }
}
