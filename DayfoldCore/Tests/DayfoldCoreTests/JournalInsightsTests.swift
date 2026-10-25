import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Journal insights") @MainActor
struct JournalInsightsTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }
    let today = at(2026, 10, 22, 18)

    var monday: Calendar { var c = ist; c.firstWeekday = 2; return c }

    func insights(_ entries: [JournalEntry] = [], _ tasks: [Entry] = [], month: Date? = nil, cal: Calendar = ist) -> JournalInsights {
        JournalInsights(entries: entries, tasks: tasks, containing: month ?? today, today: today, calendar: cal)
    }
    func days(_ row: [CalendarDay?]) -> [Int?] { row.map { $0?.day } }
    func done(_ closed: Date, kind: EntryKind = .task, status: EntryStatus = .done) -> Entry {
        let e = Entry(text: "t", kind: kind, createdAt: at(2026, 10, 1, 9), calendar: ist)
        e.status = status; e.closedAt = closed
        context.insert(e)
        return e
    }
    func day(_ i: JournalInsights, _ d: Int) -> CalendarDay { i.weeks.flatMap { $0 }.compactMap { $0 }.first { $0.day == d }! }

    @Test func octoberSundayFirst() {
        let w = insights().weeks
        #expect(w.count == 5)
        #expect(days(w[0]) == [nil, nil, nil, nil, 1, 2, 3])
        #expect(days(w[4]) == [25, 26, 27, 28, 29, 30, 31])
    }

    @Test func octoberMondayFirst() {
        let w = insights(cal: monday).weeks
        #expect(days(w[0]) == [nil, nil, nil, 1, 2, 3, 4])
        #expect(days(w.last!) == [26, 27, 28, 29, 30, 31, nil])
    }

    @Test func sixRowMonth() {
        let w = insights(month: at(2026, 8, 15)).weeks
        #expect(w.count == 6)
        #expect(days(w[0]) == [nil, nil, nil, nil, nil, nil, 1])
        #expect(days(w[5]) == [30, 31, nil, nil, nil, nil, nil])
    }

    @Test func fourRowFebruary() {
        let w = insights(month: at(2027, 2, 10), cal: monday).weeks
        #expect(w.count == 4)
        #expect(days(w[0]) == Array(1...7))
        #expect(days(w[3]) == Array(22...28))
    }

    @Test func doneCountsAndLevels() {
        let tasks = [done(at(2026, 10, 20, 9)), done(at(2026, 10, 20, 12)), done(at(2026, 10, 20, 15)),
                     done(at(2026, 10, 21, 9)), done(at(2026, 10, 21, 10), status: .dropped),
                     done(at(2026, 10, 21, 11), kind: .note)]
        let i = insights([], tasks)
        #expect(day(i, 20).doneCount == 3)
        #expect(day(i, 21).doneCount == 1)
        #expect([0, 2, 3, 5, 6].map(JournalInsights.level(for:)) == [0, 1, 2, 2, 3])
    }

    @Test func entryNearMidnight() {
        let late = JournalEntry(date: at(2026, 10, 20, 23).addingTimeInterval(59 * 60))
        let early = JournalEntry(date: at(2026, 10, 21).addingTimeInterval(30 * 60))
        let i = insights([late, early])
        #expect(day(i, 20).hasEntry && day(i, 21).hasEntry)
        #expect(!day(i, 19).hasEntry && !day(i, 22).hasEntry)
        let onlyLate = insights([late])
        #expect(day(onlyLate, 20).hasEntry && !day(onlyLate, 21).hasEntry)
    }

    @Test func todayAndFuture() {
        let i = insights()
        #expect(day(i, 22).isToday && !day(i, 22).isFuture)
        #expect(day(i, 23).isFuture && !day(i, 23).isToday)
        #expect(!day(i, 21).isToday && !day(i, 21).isFuture)
    }

    @Test func counts() {
        let es = [at(2026, 10, 3, 9), at(2026, 10, 3, 20), at(2026, 10, 20, 9), at(2026, 1, 5, 9), at(2025, 12, 30, 9)]
            .map { JournalEntry(date: $0) }
        let i = insights(es)
        #expect(i.entriesThisYear == 4)
        #expect(i.daysWrittenThisMonth == 2)
    }
}
