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

/// How a repeating task comes back. Stored on `Entry` as `rawValue`.
public enum RepeatRule: Hashable, Sendable {
    case daily, weekdays
    /// `weekday` is 1...7 (Calendar numbering, 1 = Sunday); nil until anchored by `Entry.setRepeat`.
    case weekly(weekday: Int?)
    /// `day` is 1...31; nil until anchored by `Entry.setRepeat`.
    case monthly(day: Int?)

    public init?(rawValue: String) {
        switch rawValue {
        case "daily": self = .daily
        case "weekdays": self = .weekdays
        case "weekly": self = .weekly(weekday: nil)
        case "monthly": self = .monthly(day: nil)
        default:
            if rawValue.hasPrefix("weekly:") {
                let n = Int(rawValue.dropFirst("weekly:".count))
                self = .weekly(weekday: n.flatMap { (1...7).contains($0) ? $0 : nil })
                return
            }
            guard rawValue.hasPrefix("monthly:") else { return nil }
            let n = Int(rawValue.dropFirst("monthly:".count))
            self = .monthly(day: n.flatMap { (1...31).contains($0) ? $0 : nil })
        }
    }

    public var rawValue: String {
        switch self {
        case .daily: "daily"
        case .weekdays: "weekdays"
        case .weekly(let weekday): weekday.map { "weekly:\($0)" } ?? "weekly"
        case .monthly(let day): day.map { "monthly:\($0)" } ?? "monthly"
        }
    }

    /// The picker choice: weekly / monthly without their anchor.
    public var choice: RepeatRule {
        switch self {
        case .weekly: .weekly(weekday: nil)
        case .monthly: .monthly(day: nil)
        default: self
        }
    }

    public var title: String {
        switch self {
        case .daily: "Daily"
        case .weekdays: "Weekdays"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }

    public var summary: String {
        switch self {
        case .daily: "Repeats daily"
        case .weekdays: "Repeats on weekdays"
        case .weekly: "Repeats weekly"
        case .monthly: "Repeats monthly"
        }
    }
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
    /// Flagged as important. Sorts first within its group.
    public var isPriority: Bool = false
    /// `RepeatRule.rawValue`, nil when the task doesn't repeat.
    public var repeatRaw: String?
    /// Shared by every occurrence of a repeating task; set when a repeat is first chosen.
    public var seriesID: UUID?
    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.entry)
    public var checklist: [ChecklistItem]?

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

public extension Entry {
    var repeatRule: RepeatRule? { repeatRaw.flatMap(RepeatRule.init(rawValue:)) }

    /// Weekly or monthly without an anchor is anchored on `showOn`'s weekday or day. Any repeat starts a series.
    func setRepeat(_ rule: RepeatRule?, calendar: Calendar = .current) {
        var rule = rule
        if rule == .weekly(weekday: nil) { rule = .weekly(weekday: calendar.component(.weekday, from: showOn)) }
        if rule == .monthly(day: nil) { rule = .monthly(day: calendar.component(.day, from: showOn)) }
        repeatRaw = rule?.rawValue
        if rule != nil { seriesID = seriesID ?? id }
    }
}

extension Entry: DayPageItem {}
