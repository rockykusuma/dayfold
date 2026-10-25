import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Journal feed") @MainActor
struct JournalFeedTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    /// a: plain 19 Oct · b: bookmarked 19 Oct · c: photo 20 Oct · d: bookmarked + photo 20 Oct
    private func fixtures() -> [JournalEntry] {
        let a = JournalEntry(date: at(2026,10,19,9), text: "a")
        let b = JournalEntry(date: at(2026,10,19,20), text: "b", isBookmarked: true)
        let c = JournalEntry(date: at(2026,10,20,9), text: "c")
        let d = JournalEntry(date: at(2026,10,20,23), text: "d", isBookmarked: true)
        [a, b, c, d].forEach(context.insert)
        for e in [c, d] {
            let p = JournalPhoto(data: Data([1]), order: 0)
            context.insert(p)
            p.entry = e
        }
        return [d, c, b, a]
    }

    private func texts(_ kind: JournalFeedFilter, day: Date? = nil) -> [String] {
        JournalFeed.filter(fixtures(), kind: kind, day: day, calendar: ist).map(\.text)
    }

    @Test func filters() {
        #expect(texts(.all) == ["d", "c", "b", "a"])
        #expect(texts(.bookmarked) == ["d", "b"])
        #expect(texts(.withPhotos) == ["d", "c"])
    }

    @Test func dayWithKind() {
        #expect(texts(.all, day: at(2026,10,19,12)) == ["b", "a"])
        #expect(texts(.bookmarked, day: at(2026,10,20)) == ["d"])
        #expect(texts(.withPhotos, day: at(2026,10,19)) == [])
    }

    @Test func monthsAcrossYear() {
        let entries = [at(2026,12,31,23), at(2027,1,1,0), at(2026,12,1,9), at(2027,1,15,9), at(2026,11,30,9)]
            .map { JournalEntry(date: $0) }
        entries.forEach(context.insert)
        let months = JournalFeed.months(entries, calendar: ist)
        #expect(months.map(\.id) == [at(2027,1,1), at(2026,12,1), at(2026,11,1)])
        #expect(months.map { $0.entries.map(\.date) } == [
            [at(2027,1,15,9), at(2027,1,1,0)],
            [at(2026,12,31,23), at(2026,12,1,9)],
            [at(2026,11,30,9)],
        ])
    }
}
