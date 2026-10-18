import Foundation
import SwiftData

/// One line of an entry's checklist. CloudKit rules as for `Entry`.
@Model
public final class ChecklistItem {
    public var id: UUID = UUID()
    public var text: String = ""
    public var isDone: Bool = false
    public var order: Double = 0
    public var createdAt: Date = Date()
    public var entry: Entry?

    public init(text: String, order: Double = 0, createdAt: Date = Date()) {
        self.text = text
        self.order = order
        self.createdAt = createdAt
    }
}

public extension Entry {
    /// By `order`, then `createdAt` so equal orders from concurrent appends stay stable.
    var sortedChecklist: [ChecklistItem] {
        (checklist ?? []).sorted { ($0.order, $0.createdAt) < ($1.order, $1.createdAt) }
    }

    /// Nil when there is no checklist.
    var checklistProgress: (done: Int, total: Int)? {
        let items = checklist ?? []
        return items.isEmpty ? nil : (items.filter(\.isDone).count, items.count)
    }
}

public enum Checklist {
    @discardableResult
    public static func add(_ text: String, to entry: Entry, in context: ModelContext) -> ChecklistItem? {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }
        let item = ChecklistItem(text: text, order: (entry.sortedChecklist.last?.order ?? -1) + 1)
        context.insert(item)
        item.entry = entry
        return item
    }

    /// Same arguments as `onMove`. Rewrites only the moved item's `order` (midpoint), so
    /// concurrent edits on another device don't fight; renumbers all only on a tie.
    public static func move(in entry: Entry, from source: IndexSet, to destination: Int) {
        var items = entry.sortedChecklist
        let moving = source.map { items[$0] }
        let dest = destination - source.filter { $0 < destination }.count
        items = items.enumerated().filter { !source.contains($0.offset) }.map(\.element)
        items.insert(contentsOf: moving, at: dest)
        func renumber() { items.enumerated().forEach { $1.order = Double($0) } }
        guard moving.count == 1, let i = items.firstIndex(where: { $0 === moving[0] }) else { return renumber() }
        let prev = i > 0 ? items[i - 1].order : nil
        let next = i + 1 < items.count ? items[i + 1].order : nil
        switch (prev, next) {
        case let (p?, n?) where p < n: moving[0].order = (p + n) / 2
        case (nil, let n?): moving[0].order = n - 1
        case (let p?, nil): moving[0].order = p + 1
        case (nil, nil): break
        default: renumber()  // tie from concurrent appends
        }
    }
}
