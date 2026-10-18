import Foundation
import SwiftData

/// What kind of line this is on the day page.
public enum EntryKind: String, Codable, CaseIterable, Sendable {
    /// Something to do. Carries forward until closed.
    case task
    /// A journal note. Belongs to the day it was written; never carries forward.
    case note
}

/// Work / Personal. A filter over one store, not two stores.
public enum EntryScope: String, Codable, CaseIterable, Sendable {
    case work
    case personal
}

public enum EntryStatus: String, Codable, CaseIterable, Sendable {
    case open
    case inProgress
    case done
    case dropped

    /// Open or in progress — still shows on today's page and in Review.
    public var isActive: Bool { self == .open || self == .inProgress }
}

/// One line in Dayfold. Tasks and notes share a single model so the day page is one query.
///
/// CloudKit rules (SwiftData automatic sync): every stored property has a default
/// or is optional; no `@Attribute(.unique)`; enums are stored as raw strings.
@Model
public final class Entry {
    public var id: UUID = UUID()
    /// When it was captured. Shown as the timestamp on the page.
    public var createdAt: Date = Date()
    public var kindRaw: String = EntryKind.task.rawValue
    public var text: String = ""
    public var scopeRaw: String = EntryScope.work.rawValue
    public var statusRaw: String = EntryStatus.open.rawValue
    /// When the task was closed (done or dropped). Nil while active.
    public var closedAt: Date?
    /// First day this task appears on. Defaults to the capture day; Review pushes it forward.
    public var showOn: Date = Calendar.current.startOfDay(for: Date())
    public var dueOn: Date?
    /// Who asked. Optional, free text.
    public var from: String?
    public var tags: [String] = []
    /// Who this entry is about / for / from. See `link`.
    public var person: Person?
    public var linkRaw: String?
    /// When this became "waiting on" (`link == .to`).
    public var delegatedAt: Date?
    /// Last time R followed up on a waiting item.
    public var nudgedAt: Date?

    public init(
        text: String,
        kind: EntryKind = .task,
        scope: EntryScope = .work,
        createdAt: Date = Date(),
        showOn: Date? = nil,
        dueOn: Date? = nil,
        from: String? = nil,
        tags: [String] = [],
        calendar: Calendar = .current
    ) {
        self.id = UUID()
        self.text = text
        self.kindRaw = kind.rawValue
        self.scopeRaw = scope.rawValue
        self.statusRaw = EntryStatus.open.rawValue
        self.createdAt = createdAt
        self.showOn = calendar.startOfDay(for: showOn ?? createdAt)
        self.dueOn = dueOn
        self.from = from
        self.tags = tags
    }

    public var kind: EntryKind {
        get { EntryKind(rawValue: kindRaw) ?? .task }
        set { kindRaw = newValue.rawValue }
    }

    public var scope: EntryScope {
        get { EntryScope(rawValue: scopeRaw) ?? .work }
        set { scopeRaw = newValue.rawValue }
    }

    public var status: EntryStatus {
        get { EntryStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    /// Nil when no person is attached, so a link orphaned by a sync-side delete never counts.
    public var link: PersonLink? {
        get { person == nil ? nil : linkRaw.flatMap(PersonLink.init(rawValue:)) }
        set { linkRaw = newValue?.rawValue }
    }
}

extension Entry: DayPageItem {}
