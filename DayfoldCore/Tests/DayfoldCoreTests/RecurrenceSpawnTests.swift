import Testing
import Foundation
import SwiftData
@testable import DayfoldCore

@Suite("Repeating tasks") @MainActor
struct RecurrenceSpawnTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func repeating(_ text: String, _ rule: RepeatRule, showOn: Date) -> Entry {
        let e = Entry(text: text, createdAt: showOn, calendar: ist)
        context.insert(e); e.setRepeat(rule, calendar: ist)
        return e
    }
    private func series(_ e: Entry) throws -> [Entry] {
        try context.fetch(FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.showOn)])).filter { $0.seriesID == e.seriesID }
    }

    @Test("Spawn copies the task forward with an unchecked checklist and shifted due date")
    func spawnCopies() throws {
        let meera = Person(name: "Meera"); context.insert(meera)
        let e = repeating("Weekly report", .weekly, showOn: at(2026,10,19,9))
        e.scope = .personal; e.tags = ["reports"]; e.isPriority = true; e.from = "Meera"
        e.person = meera; e.link = .from; e.dueOn = at(2026,10,21)
        for (i, t) in ["collect metrics", "send"].enumerated() {
            let item = ChecklistItem(text: t, order: Double(i)); context.insert(item); item.entry = e; item.isDone = true
        }
        let now = at(2026,10,19,18)
        Review.apply(.done, to: e, now: now, calendar: ist, context: context)
        let all = try series(e)
        #expect(all.count == 2)
        let next = try #require(all.last)
        #expect(next.id != e.id && next.status == .open && next.closedAt == nil)
        #expect(next.text == "Weekly report" && next.kind == .task && next.scope == .personal)
        #expect(next.tags == ["reports"] && next.isPriority && next.repeatRaw == "weekly")
        #expect(next.seriesID == e.id && e.seriesID == e.id)
        #expect(next.person?.id == meera.id && next.link == .from && next.from == "Meera")
        #expect(next.showOn == at(2026,10,26) && next.dueOn == at(2026,10,28) && next.createdAt == now)
        let items = (next.checklist ?? []).sorted { $0.order < $1.order }
        #expect(items.map(\.text) == ["collect metrics", "send"] && items.allSatisfy { !$0.isDone })
        #expect(e.checklist?.count == 2)
    }

    @Test("A repeating delegated task comes back delegated with a fresh waiting clock")
    func delegatedRepeats() throws {
        let arjun = Person(name: "Arjun"); context.insert(arjun)
        let e = repeating("Status from Arjun", .daily, showOn: at(2026,10,19,9))
        Review.delegate(e, to: arjun, now: at(2026,10,19,9))
        e.nudgedAt = at(2026,10,19,15)
        let now = at(2026,10,19,18)
        Review.apply(.done, to: e, now: now, calendar: ist, context: context)   // "Got it"
        let next = try #require(try series(e).last)
        #expect(next.isWaiting && next.person?.id == arjun.id)
        #expect(next.delegatedAt == now && next.nudgedAt == nil && next.showOn == at(2026,10,20))
    }

    @Test("Notes and one-off tasks never spawn")
    func noSpawn() {
        let note = Entry(text: "n", kind: .note); context.insert(note); note.repeatRaw = "daily"
        let once = Entry(text: "t"); context.insert(once)
        #expect(Recurrence.spawnNext(from: note, closedOn: at(2026,10,19), in: context, calendar: ist) == nil)
        #expect(Recurrence.spawnNext(from: once, closedOn: at(2026,10,19), in: context, calendar: ist) == nil)
    }

    @Test("Drop spawns too; the context-free apply never spawns")
    func applyOverloads() throws {
        let a = repeating("a", .daily, showOn: at(2026,10,19))
        Review.apply(.drop, to: a, now: at(2026,10,19,18), calendar: ist, context: context)
        #expect(try series(a).count == 2)
        let b = repeating("b", .daily, showOn: at(2026,10,19))
        Review.apply(.done, to: b, now: at(2026,10,19,18), calendar: ist)
        #expect(try series(b).count == 1)
    }

    @Test("Done, undo, done again leaves exactly one next occurrence")   // Review Focus 2
    func doubleClose() throws {
        let e = repeating("Water plants", .daily, showOn: at(2026,10,19))
        Review.apply(.done, to: e, now: at(2026,10,19,18), calendar: ist, context: context)
        Review.reopen(e)
        #expect(try series(e).count == 2)          // reopening keeps the spawned one
        Review.apply(.done, to: e, now: at(2026,10,19,19), calendar: ist, context: context)
        #expect(try series(e).count == 2)
    }

    @Test("The series id is the first occurrence's id, so two devices agree")   // Review Focus 3
    func seriesIDIsDeterministic() throws {
        let e = Entry(text: "Legacy", createdAt: at(2026,10,19), calendar: ist)
        context.insert(e); e.repeatRaw = "daily"                 // set without setRepeat: seriesID nil
        let next = try #require(Recurrence.spawnNext(from: e, closedOn: at(2026,10,19,18), in: context, calendar: ist))
        #expect(e.seriesID == e.id && next.seriesID == e.id)
    }

    @Test("Dedupe removes open duplicates of one occurrence, keeping the oldest")   // Review Focus 3
    func dedupe() throws {
        let sid = UUID()
        func occ(_ created: Date, showOn: Date, status: EntryStatus = .open) -> Entry {
            let e = Entry(text: "Weekly report", createdAt: created, showOn: showOn, calendar: ist)
            context.insert(e); e.repeatRaw = "weekly"; e.seriesID = sid; e.status = status
            return e
        }
        let keep = occ(at(2026,10,19,18), showOn: at(2026,10,26))
        let dup = occ(at(2026,10,19,20), showOn: at(2026,10,26))
        let item = ChecklistItem(text: "x"); context.insert(item); item.entry = dup
        let closed = occ(at(2026,10,19,21), showOn: at(2026,10,26), status: .done)
        let earlier = occ(at(2026,10,12,18), showOn: at(2026,10,19))
        let ids = (keep: keep.id, closed: closed.id, earlier: earlier.id)
        try context.save()
        try Recurrence.dedupe(in: context); try context.save()
        let left = try context.fetch(FetchDescriptor<Entry>()).filter { $0.seriesID == sid }.map(\.id)
        #expect(Set(left) == [ids.keep, ids.closed, ids.earlier])
        #expect(try context.fetch(FetchDescriptor<ChecklistItem>()).isEmpty)
    }

    @Test("Maintenance.tidy links people and removes duplicate repeats; PeopleDirectory.tidy delegates")
    func tidy() throws {
        let legacy = Entry(text: "x", from: "priya"); context.insert(legacy)
        let sid = UUID()
        for h in [18, 20] {
            let e = Entry(text: "r", createdAt: at(2026,10,19,h), showOn: at(2026,10,20), calendar: ist)
            context.insert(e); e.seriesID = sid; e.repeatRaw = "daily"
        }
        try Maintenance.tidy(in: context)
        #expect(legacy.person?.name == "Priya")
        #expect(try context.fetch(FetchDescriptor<Entry>()).filter { $0.seriesID == sid }.count == 1)
        try PeopleDirectory.tidy(in: context)
    }
}
