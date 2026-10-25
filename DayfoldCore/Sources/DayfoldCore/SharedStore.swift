import Foundation
import SwiftData

/// Where the app's store lives: the App Group, so the widget can read it.
public enum SharedStore {
    public static let appGroup = "group.com.rockykusuma.dayfold"
    public static let cloudKitID = "iCloud.com.rockykusuma.dayfold"

    /// Every model in the store, in one place for the app, the widget and demo data.
    public static let models: [any PersistentModel.Type] = [Entry.self, Person.self, ChecklistItem.self, DayNote.self,
                                                             JournalEntry.self, JournalPhoto.self, NotePage.self]

    /// The store file SwiftData used before the App Group (and still uses when the group isn't available).
    public static var legacyURL: URL { URL.applicationSupportDirectory.appending(path: "default.store") }

    /// The store in the App Group. Nil when the build has no App Group entitlement (unsigned builds).
    public static var groupURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appending(path: "Library/Application Support/default.store")
    }

    /// Copies a pre-App-Group store into the group once, then removes the old files. Both URLs name the same file
    /// (`default.store`); SQLite's `-wal` / `-shm` and `.default_SUPPORT` (external photo data) come along.
    /// The main file is copied last, so its presence means a finished copy; leftovers from an interrupted one are replaced.
    /// Returns where the store is now: `new` on success or when there was nothing to move; `old` if copying failed
    /// (the old files stay untouched and the partial copy is removed, so nothing is lost).
    @discardableResult
    public static func moveStore(from old: URL, to new: URL, fileManager fm: FileManager = .default) -> URL {
        let toDir = new.deletingLastPathComponent()
        try? fm.createDirectory(at: toDir, withIntermediateDirectories: true)   // a fresh group container has none
        guard fm.fileExists(atPath: old.path), !fm.fileExists(atPath: new.path) else { return new }
        let name = old.lastPathComponent, fromDir = old.deletingLastPathComponent()
        let sidecars = [name + "-wal", name + "-shm", "." + old.deletingPathExtension().lastPathComponent + "_SUPPORT"]
        for part in sidecars { try? fm.removeItem(at: toDir.appending(path: part)) }   // from an interrupted copy
        let parts = (sidecars + [name]).filter { fm.fileExists(atPath: fromDir.appending(path: $0).path) }
        do {
            for part in parts { try fm.copyItem(at: fromDir.appending(path: part), to: toDir.appending(path: part)) }
        } catch {
            for part in parts { try? fm.removeItem(at: toDir.appending(path: part)) }
            return old
        }
        for part in parts { try? fm.removeItem(at: fromDir.appending(path: part)) }
        return new
    }
}

public extension DayPage {
    /// The widget's view of a day: open tasks (priority first, then input order) and tasks done of all tasks.
    static func glance<Item: DayPageItem>(_ items: [Item], on day: Date, calendar: Calendar = .current)
        -> (open: [Item], done: Int, total: Int) {
        let tasks = self.items(items, on: day, calendar: calendar).filter { $0.kind == .task }
        let split = prioritySplit(tasks.filter { $0.status.isActive })
        return (split.priority + split.timeline, tasks.filter { $0.status == .done }.count, tasks.count)
    }
}
