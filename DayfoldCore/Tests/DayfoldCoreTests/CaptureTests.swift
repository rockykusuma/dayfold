import Testing
import Foundation
import SwiftData
@testable import DayfoldCore

@Suite("Capture") @MainActor
struct CaptureTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    let now = at(2026,10,19,10)

    private func add(_ text: String, kind: EntryKind = .task, scope: EntryScope = .work, day: Date? = nil,
                     linkedTo: Capture.Link? = nil) -> Entry? {
        Capture.add(text, kind: kind, scope: scope, day: day ?? now, linkedTo: linkedTo, now: now, calendar: ist, in: context)
    }
    private func lines(_ text: String) -> [Entry] {
        Capture.addLines(text, scope: .work, day: now, now: now, calendar: ist, in: context)
    }

    @Test func blank() throws {
        #expect(add("   ") == nil)
        #expect(try context.fetchCount(FetchDescriptor<Entry>()) == 0)
    }

    @Test func basicTask() throws {
        let e = try #require(add("Send deck"))
        #expect(e.kind == .task && e.scope == .work && e.createdAt == now && e.showOn == at(2026,10,19))
    }

    @Test func futureDay() throws {
        #expect(try #require(add("x", day: at(2026,10,22,15))).showOn == at(2026,10,22))
    }

    @Test func parsedScopeWins() throws {
        let e = try #require(add("Buy milk #personal", scope: .work))
        #expect(e.scope == .personal && e.text == "Buy milk")
    }

    @Test func kindRules() throws {
        #expect(try #require(add("x", kind: .note)).kind == .note)
        let d = try #require(add("Deck to:Ravi", kind: .note))
        #expect(d.kind == .task && d.person?.name == "Ravi" && d.link == .to && d.delegatedAt == now)
        let p = Person(name: "Asha"); context.insert(p)
        #expect(try #require(add("y", linkedTo: .init(person: p, link: .about))).kind == .note)
        let t = try #require(add("z", kind: .note, linkedTo: .init(person: p, link: .to)))
        #expect(t.kind == .task && t.link == .to && t.delegatedAt == now && t.person?.id == p.id)
    }

    @Test func fromLinks() throws {
        let e = try #require(add("Review doc from:Meera"))
        #expect(e.person?.name == "Meera" && e.link == .from && e.from == "Meera")
    }

    @Test func toKeepsFrom() throws {
        let e = try #require(add("Deck from:Meera to:Ravi"))
        #expect(e.person?.name == "Ravi" && e.link == .to && e.delegatedAt == now && e.from == "Meera")
    }

    @Test func priorityRepeatTasksOnly() throws {
        let t = try #require(add("Standup notes ! every:day"))
        #expect(t.isPriority && t.repeatRule == .daily)
        let n = try #require(add("Standup notes ! every:day", kind: .note))
        #expect(!n.isPriority && n.repeatRule == nil)
    }

    @Test func linesSplit() {
        let r = lines("- one\n* two\n\n• three\n[ ] four\n[x] five\n1. six\n2) seven\n– eight")
        #expect(r.map(\.text) == ["one","two","three","four","five","six","seven","eight"])
    }

    @Test func crlf() {
        let r = lines("one  \r\ntwo\r\n")
        #expect(r.map(\.text) == ["one","two"])
        #expect(!r.contains { $0.text.contains("\r") })
    }

    @Test func markerOnlyLine() {
        #expect(lines("- \n[ ]\n3.\nreal").map(\.text) == ["real"])
    }

    @Test func notAMarker() {
        for s in ["-5 degrees outside", "1.5kg flour", "*important*"] {
            #expect(Capture.stripListMarker(Substring(s)) == Substring(s))
        }
    }

    @Test func singleLineSameAsAdd() {
        #expect(lines("Call Sam").map(\.text) == ["Call Sam"])
    }

    @Test func linesParse() throws {
        let text = "Call Sam from:Meera @tomorrow #ops"
        let e = try #require(lines(text).first)
        #expect(e.link == .from && e.tags == ["ops"])
        #expect(e.dueOn != nil)
        #expect(e.dueOn == CaptureParser.parse(text, now: now, calendar: ist).dueOn)
    }

    @Test func markdownChecklist() {
        #expect(lines("- [ ] Call Sam\n* [x] Done thing\n- [link](url)").map(\.text) == ["Call Sam", "Done thing", "[link](url)"])
    }

    @Test func linesKeepLink() {
        let p = Person(name: "Asha"); context.insert(p)
        let es = Capture.addLines("a\nb", scope: .work, day: now, linkedTo: .init(person: p, link: .from),
                                  now: now, calendar: ist, in: context)
        #expect(es.count == 2 && es.allSatisfy { $0.person?.id == p.id && $0.link == .from })
    }
}
