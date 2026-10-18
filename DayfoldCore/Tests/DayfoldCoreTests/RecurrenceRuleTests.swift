import Testing
import Foundation
@testable import DayfoldCore

@Suite("Recurrence dates")
struct RecurrenceRuleTests {
    func next(_ rule: RepeatRule, _ showOn: Date, closed: Date, calendar: Calendar = ist) -> Date {
        Recurrence.nextShowOn(rule: rule, after: showOn, closedOn: closed, calendar: calendar)
    }

    @Test func daily() { #expect(next(.daily, at(2026,10,19), closed: at(2026,10,19,18)) == at(2026,10,20)) }

    @Test("Closing late gives the next future date, not catch-up copies")
    func lateClose() {
        #expect(next(.daily, at(2026,10,19), closed: at(2026,10,22,9)) == at(2026,10,23))
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,11,4,9)) == at(2026,11,9))
    }

    @Test("Weekdays skip Saturday and Sunday")
    func weekdays() {
        #expect(next(.weekdays, at(2026,10,22), closed: at(2026,10,22,18)) == at(2026,10,23)) // Thu → Fri
        #expect(next(.weekdays, at(2026,10,23), closed: at(2026,10,23,18)) == at(2026,10,26)) // Fri → Mon
        #expect(next(.weekdays, at(2026,10,23), closed: at(2026,10,24,10)) == at(2026,10,26)) // closed Sat → Mon
    }

    @Test("Weekly keeps showOn's weekday even when closed mid-week")
    func weekly() {
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,10,19,18)) == at(2026,10,26))
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,10,21,9)) == at(2026,10,26))
    }

    @Test("Monthly clamps to short months and returns to its anchor")
    func monthlyClamping() {
        let r = RepeatRule.monthly(day: 31)
        #expect(next(r, at(2027,1,31), closed: at(2027,1,31,18)) == at(2027,2,28))
        #expect(next(r, at(2027,2,28), closed: at(2027,2,28,18)) == at(2027,3,31))
        #expect(next(r, at(2027,3,31), closed: at(2027,3,31,18)) == at(2027,4,30))
        #expect(next(r, at(2028,1,31), closed: at(2028,1,31,18)) == at(2028,2,29))
    }

    @Test func monthlyLateCloseAndBareMonthly() {
        #expect(next(.monthly(day: 5), at(2026,10,5), closed: at(2026,11,10,9)) == at(2026,12,5))
        #expect(next(.monthly(day: nil), at(2026,10,19), closed: at(2026,10,19,9)) == at(2026,11,19))
    }

    @Test("Across a DST change the next date is still local midnight")
    func dst() {
        var ny = Calendar(identifier: .gregorian); ny.timeZone = TimeZone(identifier: "America/New_York")!
        func nyAt(_ m: Int, _ d: Int, _ h: Int = 0) -> Date { ny.date(from: DateComponents(year: 2026, month: m, day: d, hour: h))! }
        // US clocks fall back on Sunday 2026-11-01.
        #expect(next(.daily, nyAt(10,31), closed: nyAt(10,31,20), calendar: ny) == nyAt(11,1))
        #expect(next(.daily, nyAt(11,1), closed: nyAt(11,1,20), calendar: ny) == nyAt(11,2))
        #expect(next(.weekly, nyAt(10,25), closed: nyAt(10,25,20), calendar: ny) == nyAt(11,1))
        #expect(next(.weekdays, nyAt(10,30), closed: nyAt(10,30,20), calendar: ny) == nyAt(11,2))
    }
}
