import Testing
import Foundation
import SwiftData
@testable import DayfoldCore

@Suite("Journal") @MainActor
struct JournalTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    private func entries() throws -> [JournalEntry] { try context.fetch(FetchDescriptor<JournalEntry>()) }

    private func photo(_ order: Double, to e: JournalEntry) {
        let p = JournalPhoto(data: Data([1]), order: order)
        context.insert(p)
        p.entry = e
    }

    @Test func cascadeDeletesPhotos() throws {
        let e = JournalEntry(text: "x")
        context.insert(e)
        photo(0, to: e); photo(1, to: e)
        try context.save()
        #expect(try context.fetch(FetchDescriptor<JournalPhoto>()).count == 2)
        context.delete(e)
        try context.save()
        #expect(try context.fetch(FetchDescriptor<JournalPhoto>()).isEmpty)
    }

    @Test func helpers() throws {
        let e = JournalEntry(title: "  ", text: "\n")
        context.insert(e)
        #expect(e.isBlank)
        photo(2, to: e); photo(1, to: e)
        #expect(!e.isBlank)
        #expect(e.hasPhotos)
        #expect(e.sortedPhotos.map(\.order) == [1, 2])
        e.text = "Line one\nLine two"
        #expect(e.preview == "Line one")
        e.text = "  \nfoo"
        #expect(e.preview == "foo")
        e.title = "Title"
        #expect(e.preview == "Title")
    }

    @Test func setReflectionInsertUpdate() throws {
        try Journal.setReflection("  Good  ", for: at(2026,10,19,9), now: at(2026,10,19,21), calendar: ist, in: context)
        var all = try entries()
        #expect(all.count == 1)
        #expect(all[0].isReflection)
        #expect(all[0].date == at(2026,10,19,21))
        #expect(all[0].text == "Good")
        try Journal.setReflection("Better", for: at(2026,10,19,9), now: at(2026,10,19,22), calendar: ist, in: context)
        all = try entries()
        #expect(all.count == 1)
        #expect(all[0].text == "Better")
        #expect(all[0].updatedAt == at(2026,10,19,22))
    }

    @Test func setReflectionEmpty() throws {
        try Journal.setReflection("", for: at(2026,10,20,9), calendar: ist, in: context)
        #expect(try entries().isEmpty)
        try Journal.setReflection("x", for: at(2026,10,19,9), calendar: ist, in: context)
        try Journal.setReflection("   ", for: at(2026,10,19,9), calendar: ist, in: context)
        #expect(try entries().isEmpty)
    }

    @Test func reflectionByCalendarDay() throws {
        try Journal.setReflection("x", for: at(2026,10,19,9), calendar: ist, in: context)
        context.insert(JournalEntry(date: at(2026,10,20,10), text: "plain"))
        context.insert(JournalEntry(date: at(2026,10,19,10), text: "plain19"))
        #expect(try Journal.reflection(for: at(2026,10,19,0), calendar: ist, in: context)?.text == "x")
        #expect(try Journal.reflection(for: at(2026,10,19,23), calendar: ist, in: context)?.text == "x")
        #expect(try Journal.reflection(for: at(2026,10,20,0), calendar: ist, in: context) == nil)
    }

    @Test func migrateDayNotes() throws {
        let note = DayNote(day: at(2026,10,18), text: "Good", updatedAt: at(2026,10,18,22), calendar: ist)
        context.insert(note)
        let id = note.id
        try Journal.migrateDayNotes(calendar: ist, in: context)
        let all = try entries()
        #expect(all.count == 1)
        #expect(all[0].id == id)
        #expect(all[0].date == at(2026,10,18,21))
        #expect(all[0].text == "Good")
        #expect(all[0].isReflection)
        #expect(all[0].createdAt == at(2026,10,18,22))
        #expect(all[0].updatedAt == at(2026,10,18,22))
        #expect(try context.fetch(FetchDescriptor<DayNote>()).isEmpty)
    }

    @Test func migrateIdempotent() throws {
        context.insert(DayNote(day: at(2026,10,18), text: "Good", updatedAt: at(2026,10,18,22), calendar: ist))
        try Journal.migrateDayNotes(calendar: ist, in: context)
        try Journal.migrateDayNotes(calendar: ist, in: context)
        try Journal.dedupe(calendar: ist, in: context)
        #expect(try entries().count == 1)
    }

    @Test func dedupeById() throws {
        let id = UUID()
        context.insert(JournalEntry(id: id, date: at(2026,10,19,21), text: "old", updatedAt: at(2026,10,19,20)))
        context.insert(JournalEntry(id: id, date: at(2026,10,19,21), text: "new", updatedAt: at(2026,10,19,22)))
        try Journal.dedupe(calendar: ist, in: context)
        let all = try entries()
        #expect(all.count == 1)
        #expect(all[0].text == "new")
    }

    @Test func dedupeReflections() throws {
        for (t, h) in [("A", 20), ("B", 21), ("A", 22)] {
            context.insert(JournalEntry(date: at(2026,10,19,21), text: t, isReflection: true,
                                        createdAt: at(2026,10,19,h), updatedAt: at(2026,10,19,h)))
        }
        try Journal.dedupe(calendar: ist, in: context)
        let all = try entries()
        #expect(all.count == 1)
        #expect(all[0].text == "A\nB")
        #expect(all[0].updatedAt == at(2026,10,19,22))
    }

    @Test func plainEntriesNotMerged() throws {
        context.insert(JournalEntry(date: at(2026,10,19,9), text: "a"))
        context.insert(JournalEntry(date: at(2026,10,19,10), text: "b"))
        try Journal.dedupe(calendar: ist, in: context)
        #expect(try entries().count == 2)
    }

    @Test func tidyMigratesAndDedupes() throws {
        context.insert(DayNote(day: at(2026,10,18), text: "Good", updatedAt: at(2026,10,18,22), calendar: ist))
        let id = UUID()
        context.insert(JournalEntry(id: id, date: at(2026,10,19,9), text: "old", updatedAt: at(2026,10,19,9)))
        context.insert(JournalEntry(id: id, date: at(2026,10,19,9), text: "new", updatedAt: at(2026,10,19,10)))
        try Maintenance.tidy(in: context)
        #expect(try context.fetch(FetchDescriptor<DayNote>()).isEmpty)
        let all = try entries()
        #expect(Set(all.map(\.id)).count == all.count)
        #expect(all.count == 2)
    }

    @Test func dedupeKeepsPhotos() throws {
        let id = UUID()
        let keeper = JournalEntry(id: id, text: "new", updatedAt: at(2026,10,19,22))
        let loser = JournalEntry(id: id, text: "old", updatedAt: at(2026,10,19,20))
        context.insert(keeper); context.insert(loser)
        photo(0, to: loser)
        try Journal.dedupe(calendar: ist, in: context)
        try context.save()
        let all = try entries()
        #expect(all.count == 1)
        #expect(all[0].sortedPhotos.count == 1)
        #expect(try context.fetch(FetchDescriptor<JournalPhoto>()).count == 1)
    }

    @Test func dedupeReflectionsKeepBookmark() throws {
        context.insert(JournalEntry(date: at(2026,10,19,21), text: "A", isReflection: true, updatedAt: at(2026,10,19,20)))
        context.insert(JournalEntry(date: at(2026,10,19,21), title: "T", text: "B", isBookmarked: true,
                                    isReflection: true, updatedAt: at(2026,10,19,22)))
        try Journal.dedupe(calendar: ist, in: context)
        let all = try entries()
        #expect(all.count == 1)
        #expect(all[0].isBookmarked)
        #expect(all[0].title == "T")
    }

    @Test func migrateSkipsBlank() throws {
        context.insert(DayNote(day: at(2026,10,18), text: " \n", updatedAt: at(2026,10,18,22), calendar: ist))
        try Journal.migrateDayNotes(calendar: ist, in: context)
        #expect(try entries().isEmpty)
        #expect(try context.fetch(FetchDescriptor<DayNote>()).isEmpty)
    }
}
