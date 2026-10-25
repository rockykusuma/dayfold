import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Note pages") @MainActor
struct NotePageTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    func page(_ title: String, in parent: NotePage? = nil) -> NotePage {
        let p = NotePage(title: title, parent: parent)
        context.insert(p)
        p.parent = parent
        return p
    }

    @Test func helpers() {
        #expect(page("  ").displayTitle == "Untitled")
        #expect(page(" Hi ").displayTitle == "Hi")
        let a = page("")
        #expect(a.isBlank)
        _ = page("c", in: a)
        #expect(!a.isBlank)
        let r = page("r")
        for t in ["b", "A", "c"] { _ = page(t, in: r) }
        #expect(r.sortedChildren.map(\.title) == ["A", "b", "c"])
    }

    @Test func deleteReparentsToTop() throws {
        let p = page("P"); let c1 = page("1", in: p); let c2 = page("2", in: p)
        Pages.delete(p, in: context)
        try context.save()
        #expect(c1.parent == nil && c2.parent == nil)
        #expect(try context.fetch(FetchDescriptor<NotePage>()).count == 2)
    }

    @Test func deleteMiddleKeepsGrandchildren() throws {
        let a = page("A"); let b = page("B", in: a); let c = page("C", in: b)
        Pages.delete(b, in: context)
        try context.save()
        #expect(c.parent === a)
        #expect(a.children?.contains { $0 === c } == true)
        #expect(try context.fetch(FetchDescriptor<NotePage>()).count == 2)
    }

    @Test func moveRefusesCycles() {
        let a = page("A"); let b = page("B", in: a); let c = page("C", in: b)
        #expect(!Pages.move(a, to: c))
        #expect(a.parent == nil)
        #expect(!Pages.move(a, to: a))
        let now = Date(timeIntervalSince1970: 5000)
        #expect(Pages.move(c, to: nil, now: now))
        #expect(c.parent == nil && c.updatedAt == now)
    }

    @Test func breadcrumbRootFirst() {
        let a = page("A"); let b = page("B", in: a); let c = page("C", in: b)
        #expect(Pages.breadcrumb(c).map(\.title) == ["A", "B"])
        #expect(Pages.breadcrumb(a).isEmpty)
    }

    @Test func breadcrumbCycleGuard() {
        let a = page("A"); let b = page("B", in: a)
        a.parent = b
        #expect(Pages.breadcrumb(a).count <= 50)
    }

    @Test func descendants() {
        let a = page("A"); let b = page("B", in: a); _ = page("C", in: b); _ = page("D", in: a)
        #expect(Set(Pages.descendants(of: a).map(\.title)) == ["B", "C", "D"])
    }
}
