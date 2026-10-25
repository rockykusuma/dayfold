import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Page links") @MainActor
struct PageLinksTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    func page(_ title: String, _ body: String = "", updated: Date = at(2026,10,1)) -> NotePage {
        let p = NotePage(title: title, body: body, updatedAt: updated)
        context.insert(p)
        return p
    }

    @Test func titlesParse() {
        #expect(PageLinks.titles(in: "See [[Release process]] and [[Onboarding|start here]] and [[release  process ]]")
                == ["Release process", "Onboarding"])
        #expect(PageLinks.titles(in: "[[ ]] [[]] [[open").isEmpty)
    }

    @Test func resolveNormalizes() {
        let o = page("Onboarding")
        #expect(PageLinks.resolve("onbôarding", in: [o]) === o)
        let old = page("Plan", updated: at(2026,10,1)), new = page("Plan", updated: at(2026,10,5))
        #expect(PageLinks.resolve("plan", in: [old, new]) === new)
        #expect(PageLinks.resolve("nope", in: [old]) == nil)
    }

    @Test func backlinksExcludeSelf() {
        let b = page("B")
        let a = page("A", "[[B]] [[A]]", updated: at(2026,10,2))
        let c = page("C", "[[b]]", updated: at(2026,10,3))
        #expect(PageLinks.backlinks(to: b, in: [a, b, c]).map(\.title) == ["C", "A"])
        #expect(PageLinks.backlinks(to: a, in: [a, b, c]).isEmpty)
    }

    @Test func renameRewrites() {
        let now = at(2026,10,9)
        let a = page("a", "[[Old]] and [[Old]]"), b = page("b", "[[old|label]]"), c = page("c", "none")
        PageLinks.rename(from: "Old", to: "New", in: [a, b, c], now: now)
        #expect(a.body == "[[New]] and [[New]]")
        #expect(b.body == "[[New|label]]")
        #expect(c.body == "none")
        #expect(a.updatedAt == now && b.updatedAt == now && c.updatedAt == at(2026,10,1))
    }

    @Test func renameCaseOnlyNoop() {
        let a = page("a", "[[release process]]")
        PageLinks.rename(from: "release process", to: "Release Process", in: [a], now: at(2026,10,9))
        #expect(a.body == "[[release process]]")
        #expect(a.updatedAt == at(2026,10,1))
    }

    @Test func inlineEscaping() throws {
        let md = PageLinks.inlineMarkdown("x [[Q3 & Q4 plan #1]] y")
        let attr = try AttributedString(markdown: md, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        let links = attr.runs.compactMap(\.link)
        #expect(links.count == 1)
        #expect(PageLinks.title(from: links[0]) == "Q3 & Q4 plan #1")
        #expect(String(attr.characters) == "x Q3 & Q4 plan #1 y")
        let tricky = try AttributedString(markdown: PageLinks.inlineMarkdown("[[50% (a)?|see [this]]]"))
        #expect(tricky.runs.compactMap(\.link).compactMap(PageLinks.title(from:)) == ["50% (a)?"])
    }

    @Test func completionTokens() {
        #expect(PageLinks.completionToken(in: "see [[Rel") == "Rel")
        #expect(PageLinks.completionToken(in: "see [[Rel]]") == nil)
        #expect(PageLinks.completionToken(in: "[[") == "")
        #expect(PageLinks.completionToken(in: "a [[b]] [[c") == "c")
        #expect(PageLinks.completionToken(in: "[[a\nb") == nil)
        #expect(PageLinks.completionToken(in: "none") == nil)
    }
}
