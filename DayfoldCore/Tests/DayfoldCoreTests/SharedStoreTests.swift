import Foundation
import Testing
@testable import DayfoldCore

@Suite("Shared store")
struct SharedStoreTests {
    private let fm = FileManager.default

    private func tempDir() -> URL {
        let d = fm.temporaryDirectory.appending(path: UUID().uuidString)
        try! fm.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }

    @Test func movesTheStoreWithItsSidecarsAndPhotos() throws {
        let old = tempDir().appending(path: "default.store"), new = tempDir().appending(path: "deep/dir/default.store")
        let from = old.deletingLastPathComponent()
        for f in ["default.store", "default.store-wal", "default.store-shm", "other.txt"] {
            try Data(f.utf8).write(to: from.appending(path: f))
        }
        try fm.createDirectory(at: from.appending(path: ".default_SUPPORT/_EXTERNAL_DATA"), withIntermediateDirectories: true)
        try Data("photo".utf8).write(to: from.appending(path: ".default_SUPPORT/_EXTERNAL_DATA/p1"))

        #expect(SharedStore.moveStore(from: old, to: new) == new)
        let to = new.deletingLastPathComponent()
        #expect(try String(contentsOf: to.appending(path: "default.store-wal"), encoding: .utf8) == "default.store-wal")
        #expect(fm.fileExists(atPath: to.appending(path: "default.store-shm").path))
        #expect(fm.fileExists(atPath: to.appending(path: ".default_SUPPORT/_EXTERNAL_DATA/p1").path))
        #expect(!fm.fileExists(atPath: old.path))
        #expect(!fm.fileExists(atPath: from.appending(path: ".default_SUPPORT").path))
        #expect(fm.fileExists(atPath: from.appending(path: "other.txt").path))   // only the store's files move
    }

    @Test func neverOverwritesAnExistingGroupStore() throws {
        let old = tempDir().appending(path: "default.store"), new = tempDir().appending(path: "default.store")
        try Data("old".utf8).write(to: old)
        try Data("new".utf8).write(to: new)
        #expect(SharedStore.moveStore(from: old, to: new) == new)
        #expect(try String(contentsOf: new, encoding: .utf8) == "new")
        #expect(fm.fileExists(atPath: old.path))
    }

    @Test func nothingToMoveUsesTheGroupAndMakesItsFolder() {
        let old = tempDir().appending(path: "default.store"), new = tempDir().appending(path: "Library/Support/default.store")
        #expect(SharedStore.moveStore(from: old, to: new) == new)
        #expect(fm.fileExists(atPath: new.deletingLastPathComponent().path))
    }

    @Test func anInterruptedCopyIsRedone() throws {
        let old = tempDir().appending(path: "default.store"), new = tempDir().appending(path: "default.store")
        try Data("old".utf8).write(to: old)
        try Data("fresh wal".utf8).write(to: old.deletingLastPathComponent().appending(path: "default.store-wal"))
        // Killed mid-copy last time: a sidecar landed, the main file didn't.
        try Data("stale wal".utf8).write(to: new.deletingLastPathComponent().appending(path: "default.store-wal"))
        #expect(SharedStore.moveStore(from: old, to: new) == new)
        #expect(try String(contentsOf: new.deletingLastPathComponent().appending(path: "default.store-wal"), encoding: .utf8) == "fresh wal")
        #expect(try String(contentsOf: new, encoding: .utf8) == "old")
    }

    @Test func aFailedCopyKeepsTheOldStore() throws {
        let old = tempDir().appending(path: "default.store")
        try Data("old".utf8).write(to: old)
        try Data("x".utf8).write(to: old.deletingLastPathComponent().appending(path: "default.store-wal"))
        // The new "directory" is a file, so creating it fails.
        let blocker = tempDir().appending(path: "blocker")
        try Data().write(to: blocker)
        #expect(SharedStore.moveStore(from: old, to: blocker.appending(path: "default.store")) == old)
        #expect(try String(contentsOf: old, encoding: .utf8) == "old")
        #expect(fm.fileExists(atPath: old.deletingLastPathComponent().appending(path: "default.store-wal").path))
    }

    @Test func glanceCountsTodaysTasksAndListsOpenOnesPriorityFirst() {
        let mon = at(2026, 10, 19, 9), tue = at(2026, 10, 20, 9)
        func t(_ created: Date, _ status: EntryStatus = .open, closed: Date? = nil, priority: Bool = false,
               kind: EntryKind = .task) -> FakeItem {
            FakeItem(createdAt: created, kind: kind, status: status, closedAt: closed,
                     showOn: ist.startOfDay(for: created), isPriority: priority)
        }
        let carried = t(mon)
        let star = t(tue, priority: true)
        let doneToday = t(mon, .done, closed: tue)
        let doneYesterday = t(mon, .done, closed: mon)
        let note = t(tue, kind: .note)
        let tomorrow = t(at(2026, 10, 21, 9))
        let g = DayPage.glance([carried, star, doneToday, doneYesterday, note, tomorrow], on: tue, calendar: ist)
        #expect(g.open.map(\.createdAt) == [star.createdAt, carried.createdAt])
        #expect(g.done == 1 && g.total == 3)
    }
}
