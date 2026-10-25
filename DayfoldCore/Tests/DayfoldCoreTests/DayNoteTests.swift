import Testing
import Foundation
import SwiftData
@testable import DayfoldCore

@Suite("Day notes") @MainActor
struct DayNoteTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    private func all() throws -> [DayNote] { try context.fetch(FetchDescriptor<DayNote>()) }

    @Test func insertAndUpdate() throws {
        try DayNotes.set("Good day", for: at(2026,10,19,21), now: at(2026,10,19,21), calendar: ist, in: context)
        var notes = try all()
        #expect(notes.count == 1)
        #expect(notes[0].day == at(2026,10,19))
        #expect(notes[0].text == "Good day")
        try DayNotes.set("Better", for: at(2026,10,19,21), now: at(2026,10,19,22), calendar: ist, in: context)
        notes = try all()
        #expect(notes.count == 1)
        #expect(notes[0].text == "Better")
        #expect(notes[0].updatedAt == at(2026,10,19,22))
    }

    @Test func trims() throws {
        try DayNotes.set("  hi \n", for: at(2026,10,19,9), calendar: ist, in: context)
        #expect(try all().first?.text == "hi")
    }

    @Test func emptyDeletes() throws {
        try DayNotes.set("x", for: at(2026,10,19,9), calendar: ist, in: context)
        try DayNotes.set("   ", for: at(2026,10,19,9), calendar: ist, in: context)
        #expect(try all().isEmpty)
    }

    @Test func emptyNoOp() throws {
        try DayNotes.set("", for: at(2026,10,20,9), calendar: ist, in: context)
        #expect(try all().isEmpty)
    }

    @Test func noteAnyTime() throws {
        try DayNotes.set("x", for: at(2026,10,19,0).addingTimeInterval(300), calendar: ist, in: context)
        #expect(try DayNotes.note(for: at(2026,10,19,23), calendar: ist, in: context)?.text == "x")
        #expect(try DayNotes.note(for: at(2026,10,20,0), calendar: ist, in: context) == nil)
    }

    private func seedDuplicates() {
        for (t, h) in [("A", 20), ("B", 21), ("A", 22)] {
            context.insert(DayNote(day: at(2026,10,19), text: t, updatedAt: at(2026,10,19,h), calendar: ist))
        }
        context.insert(DayNote(day: at(2026,10,20), text: "C", updatedAt: at(2026,10,20,9), calendar: ist))
    }

    @Test func dedupeMerges() throws {
        seedDuplicates()
        try DayNotes.dedupe(in: context)
        let notes = try all()
        #expect(notes.count == 2)
        let merged = try #require(notes.first { $0.day == at(2026,10,19) })
        #expect(merged.text == "A\nB")
        #expect(merged.updatedAt == at(2026,10,19,22))
    }

    @Test func dedupeSameCalendarDay() throws {
        let a = DayNote(day: at(2026,10,19), text: "A", updatedAt: at(2026,10,19,20), calendar: ist)
        let b = DayNote(day: at(2026,10,19), text: "B", updatedAt: at(2026,10,19,21), calendar: ist)
        b.day = at(2026,10,19,5)  // as if written in another time zone
        context.insert(a); context.insert(b)
        try DayNotes.dedupe(calendar: ist, in: context)
        let notes = try all()
        #expect(notes.count == 1)
        #expect(notes[0].text == "A\nB")
    }

    @Test func tidyDedupes() throws {
        context.insert(DayNote(day: at(2026,10,19), text: "A", updatedAt: at(2026,10,19,20), calendar: ist))
        context.insert(DayNote(day: at(2026,10,19), text: "B", updatedAt: at(2026,10,19,21), calendar: ist))
        try Maintenance.tidy(in: context)
        #expect(try all().count == 1)
    }
}
