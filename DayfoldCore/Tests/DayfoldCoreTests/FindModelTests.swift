import Testing
import Foundation
import SwiftData
@testable import DayfoldCore

@Suite("Find & organise model") @MainActor
struct FindModelTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test func newFieldsDefault() {
        let e = Entry(text: "x")
        #expect(e.isPriority == false && e.repeatRaw == nil && e.seriesID == nil && e.repeatRule == nil)
        #expect((e.checklist ?? []).isEmpty)
    }

    @Test func repeatRuleRawValues() {
        for raw in ["daily", "weekdays", "weekly", "monthly:31"] { #expect(RepeatRule(rawValue: raw)?.rawValue == raw) }
        #expect(RepeatRule(rawValue: "monthly") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "monthly:0") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "monthly:x") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "fortnightly") == nil)
        #expect(RepeatRule.monthly(day: nil).rawValue == "monthly")
        #expect(RepeatRule.monthly(day: 12).choice == .monthly(day: nil) && RepeatRule.weekly.choice == .weekly)
        #expect(RepeatRule.weekdays.summary == "Repeats on weekdays" && RepeatRule.monthly(day: 3).title == "Monthly")
    }

    @Test("Choosing Monthly anchors on showOn's day and starts a series")
    func setRepeatAnchors() {
        let e = Entry(text: "Rent", createdAt: at(2027, 1, 31, 9), calendar: ist)
        e.setRepeat(.monthly(day: nil), calendar: ist)
        #expect(e.repeatRaw == "monthly:31" && e.seriesID == e.id)
        e.setRepeat(nil, calendar: ist)
        #expect(e.repeatRaw == nil && e.seriesID == e.id)
    }

    @Test("Deleting an entry deletes its checklist")
    func checklistCascades() throws {
        let e = Entry(text: "Ship"); context.insert(e)
        for t in ["a", "b"] { let i = ChecklistItem(text: t); context.insert(i); i.entry = e }
        try context.save()
        #expect(e.checklist?.count == 2)
        context.delete(e); try context.save()
        #expect(try context.fetch(FetchDescriptor<ChecklistItem>()).isEmpty)
    }
}
