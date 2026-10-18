import Foundation
import SwiftData

public extension Person {
    /// What R owes this person: open tasks they asked for, oldest first.
    var owed: [Entry] {
        (entries ?? []).filter { $0.kind == .task && $0.link == .from && $0.status.isActive }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// What R is waiting on this person for, oldest first.
    var waiting: [Entry] {
        (entries ?? []).filter(\.isWaiting).sorted { $0.createdAt < $1.createdAt }
    }

    /// 1:1 notes about this person, newest first.
    var notes: [Entry] {
        (entries ?? []).filter { $0.kind == .note && $0.link == .about }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func oldestWaitingDays(on day: Date, calendar: Calendar = .current) -> Int? {
        waiting.map { Review.waitingDays($0, on: day, calendar: calendar) }.max()
    }
}

public struct WaitingGroup: Identifiable {
    public let person: Person
    public let entries: [Entry]
    public let oldestDays: Int
    public var id: PersistentIdentifier { person.persistentModelID }
}

public enum PersonPage {
    /// Everyone R is waiting on, with their items; longest wait first.
    public static func allWaiting(_ people: [Person], on day: Date, calendar: Calendar = .current) -> [WaitingGroup] {
        people.compactMap { person in
            let items = person.waiting
            guard let oldest = person.oldestWaitingDays(on: day, calendar: calendar), !items.isEmpty else { return nil }
            return WaitingGroup(person: person, entries: items, oldestDays: oldest)
        }
        .sorted { $0.oldestDays > $1.oldestDays }
    }
}
