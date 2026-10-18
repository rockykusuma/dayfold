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
