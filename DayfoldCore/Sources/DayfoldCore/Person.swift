import Foundation
import SwiftData

public enum PersonRole: String, Codable, CaseIterable, Sendable {
    case report, manager, peer, other
}

/// How an entry relates to its person.
public enum PersonLink: String, Codable, CaseIterable, Sendable {
    /// They asked me — shows under "You owe".
    case from
    /// I'm waiting on them — delegated work.
    case to
    /// A 1:1 note about them.
    case about
}

/// Someone R works with. Created automatically from `from:` / `to:` in capture.
/// CloudKit rules: defaults everywhere, no unique attributes, optional relationship with inverse.
@Model
public final class Person {
    public var id: UUID = UUID()
    public var name: String = ""
    public var roleRaw: String = PersonRole.other.rawValue
    public var team: String?
    public var createdAt: Date = Date()
    /// False until R saves the Edit sheet; drives the "Unsorted" list.
    public var isSorted: Bool = false
    @Relationship(deleteRule: .nullify, inverse: \Entry.person)
    public var entries: [Entry]?

    public init(name: String, role: PersonRole = .other, team: String? = nil, createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.roleRaw = role.rawValue
        self.team = team
        self.createdAt = createdAt
    }

    public var role: PersonRole {
        get { PersonRole(rawValue: roleRaw) ?? .other }
        set { roleRaw = newValue.rawValue }
    }
}
