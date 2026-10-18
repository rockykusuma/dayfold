import Foundation
import Testing
@testable import DayfoldCore

@Suite("Capture parser")
struct CaptureParserTests {
    let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
        return c
    }()
    // Sunday 2026-10-18
    var now: Date { cal.date(from: DateComponents(year: 2026, month: 10, day: 18, hour: 10))! }

    @Test func plainTextPassesThrough() {
        let p = CaptureParser.parse("Review ICD doc", now: now, calendar: cal)
        #expect(p == ParsedCapture(text: "Review ICD doc", scope: nil, from: nil, dueOn: nil, tags: []))
    }

    @Test func extractsScopeFromAndTags() {
        let p = CaptureParser.parse("Fix build from:priya #work #urgent", now: now, calendar: cal)
        #expect(p.text == "Fix build")
        #expect(p.scope == .work)
        #expect(p.from == "priya")
        #expect(p.tags == ["urgent"])
    }

    @Test func dueTomorrowAndWeekday() {
        let tmrw = CaptureParser.parse("x @tomorrow", now: now, calendar: cal).dueOn
        #expect(tmrw == cal.date(from: DateComponents(year: 2026, month: 10, day: 19)))
        let fri = CaptureParser.parse("x @fri", now: now, calendar: cal).dueOn
        #expect(fri == cal.date(from: DateComponents(year: 2026, month: 10, day: 23)))
    }

    @Test func dueISODate() {
        let d = CaptureParser.parse("x @2026-11-02", now: now, calendar: cal).dueOn
        #expect(d == cal.date(from: DateComponents(year: 2026, month: 11, day: 2)))
    }

    @Test func unknownAtTokenIsKeptAsText() {
        let p = CaptureParser.parse("ping @priya", now: now, calendar: cal)
        #expect(p.text == "ping @priya")
        #expect(p.dueOn == nil)
    }

    @Test func extractsTo() {
        let p = CaptureParser.parse("Q4 capacity numbers to:arjun", now: now, calendar: cal)
        #expect(p.text == "Q4 capacity numbers")
        #expect(p.to == "arjun")
        #expect(p.from == nil)
    }

    @Test func fromAndToTogether() {
        let p = CaptureParser.parse("Deck from:meera to:priya_s", now: now, calendar: cal)
        #expect(p.from == "meera" && p.to == "priya_s")
    }

    @Test("Trailing punctuation is not part of a name")
    func trailingPunctuation() {
        let p = CaptureParser.parse("Ping to:arjun, about from:priya.", now: now, calendar: cal)
        #expect(p.to == "arjun" && p.from == "priya")
        #expect(p.text == "Ping about")
    }

    @Test func emptyToIsKeptAsText() {
        let p = CaptureParser.parse("walk to: the office", now: now, calendar: cal)
        #expect(p.to == nil)
        #expect(p.text == "walk to: the office")
    }
}
