import Foundation
import SwiftData

/// A wiki page. CloudKit rules as for `Entry`: defaulted/optional properties, optional relationships.
@Model
public final class NotePage {
    public var id: UUID = UUID()
    public var title: String = ""
    public var body: String = ""
    public var isPinned: Bool = false
    public var createdAt: Date = Date()
    public var updatedAt: Date = Date()
    public var parent: NotePage?
    @Relationship(deleteRule: .nullify, inverse: \NotePage.parent) public var children: [NotePage]?

    public init(title: String = "", body: String = "", isPinned: Bool = false, parent: NotePage? = nil,
                createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.title = title
        self.body = body
        self.isPinned = isPinned
        self.parent = parent
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    public var displayTitle: String {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Untitled" : t
    }

    public var isBlank: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (children ?? []).isEmpty
    }

    public var sortedChildren: [NotePage] {
        Pages.sorted(children ?? [])
    }
}

public enum Pages {
    /// By title (Finder order), then oldest first, then id, so equal titles never swap places between renders.
    public static func sorted(_ pages: [NotePage]) -> [NotePage] {
        pages.sorted { a, b in
            switch a.displayTitle.localizedStandardCompare(b.displayTitle) {
            case .orderedAscending: return true
            case .orderedDescending: return false
            case .orderedSame: return a.createdAt != b.createdAt ? a.createdAt < b.createdAt : a.id.uuidString < b.id.uuidString
            }
        }
    }

    /// Subpages move up a level; nothing below is deleted. Doesn't save (autosave).
    public static func delete(_ page: NotePage, in context: ModelContext) {
        let up = page.parent
        for child in page.children ?? [] { child.parent = up }
        context.delete(page)
    }

    /// False (nothing changed) when `newParent` is the page or one of its descendants.
    @discardableResult
    public static func move(_ page: NotePage, to newParent: NotePage?, now: Date = Date()) -> Bool {
        if let newParent, newParent === page || descendants(of: page).contains(where: { $0 === newParent }) { return false }
        page.parent = newParent
        page.updatedAt = now
        return true
    }

    /// Ancestors, root first. Stops at 50 so a sync-made cycle can't hang.
    public static func breadcrumb(_ page: NotePage) -> [NotePage] {
        var chain: [NotePage] = []
        var cur = page.parent
        while let p = cur, chain.count < 50 {
            chain.append(p)
            cur = p.parent
        }
        return chain.reversed()
    }

    public static func descendants(of page: NotePage) -> [NotePage] {
        var out: [NotePage] = []
        var seen: Set<UUID> = [page.id]
        var queue = page.children ?? []
        while !queue.isEmpty {
            let p = queue.removeFirst()
            guard seen.insert(p.id).inserted else { continue }
            out.append(p)
            queue += p.children ?? []
        }
        return out
    }
}
