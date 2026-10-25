import Foundation
import Testing
@testable import DayfoldCore

/// `⟨…⟩` marks the selection, `‸` the caret.
private func e(_ s: String) -> PageEdit {
    var text = "", lo = 0, hi = 0, n = 0
    for ch in s {
        switch ch {
        case "‸": lo = n; hi = n
        case "⟨": lo = n
        case "⟩": hi = n
        default: text.append(ch); n += 1
        }
    }
    return PageEdit(text: text, selection: lo..<hi)
}

private func show(_ edit: PageEdit) -> String {
    var c = Array(edit.text).map(String.init)
    if edit.selection.isEmpty { c.insert("‸", at: edit.selection.lowerBound) } else {
        c.insert("⟩", at: edit.selection.upperBound)
        c.insert("⟨", at: edit.selection.lowerBound)
    }
    return c.joined()
}

@Suite("Page format")
struct PageFormatTests {
    @Test func numberedBlocks() {
        #expect(PageMarkup.blocks("1. a\n  2) b\n2024 was\n3.no") == [
            .numbered(number: 1, text: "a", indent: 0), .numbered(number: 2, text: "b", indent: 1),
            .paragraph("2024 was\n3.no")])
    }

    @Test func lineStyles() {
        #expect(show(PageFormat.setStyle(.title, e("He‸llo"))) == "# He‸llo")
        #expect(show(PageFormat.setStyle(.heading, e("# He‸llo"))) == "## He‸llo")
        #expect(show(PageFormat.setStyle(.subheading, e("‸"))) == "### ‸")
        #expect(show(PageFormat.setStyle(.body, e("- [x] do‸ne"))) == "do‸ne")
        #expect(show(PageFormat.setStyle(.quote, e("‸a"))) == "> ‸a")
    }

    @Test func styleTogglesOffWhenAllHaveIt() {
        #expect(show(PageFormat.setStyle(.bullet, e("- ‸a"))) == "‸a")
        #expect(show(PageFormat.setStyle(.title, e("# ‸a"))) == "‸a")
    }

    @Test func listsKeepIndentAndMarkerSwaps() {
        #expect(show(PageFormat.setStyle(.checklist, e("  - a‸"))) == "  - [ ] a‸")
        #expect(show(PageFormat.setStyle(.bullet, e("  1. a‸"))) == "  - a‸")
        #expect(show(PageFormat.setStyle(.numbered, e("  - [ ] a‸"))) == "  1. a‸")
    }

    @Test func multiLineStylesAndNumbering() {
        #expect(show(PageFormat.setStyle(.numbered, e("⟨a\nb\nc⟩\nd"))) == "1. ⟨a\n2. b\n3. c⟩\nd")
        #expect(show(PageFormat.setStyle(.numbered, e("1. x\n⟨a\nb⟩"))) == "1. x\n2. ⟨a\n3. b⟩")
        // Mixed: the ones already bulleted stay, the rest join.
        #expect(show(PageFormat.setStyle(.bullet, e("⟨- a\nb⟩"))) == "- ⟨a\n- b⟩")
        // A selection ending just after a line break leaves the next line alone.
        #expect(show(PageFormat.setStyle(.bullet, e("⟨a\n⟩b"))) == "- ⟨a\n⟩b")
    }

    @Test func wrapAndUnwrap() {
        #expect(show(PageFormat.toggleWrap(PageFormat.bold, e("a ⟨big⟩ b"))) == "a **⟨big⟩** b")
        #expect(show(PageFormat.toggleWrap(PageFormat.bold, e("a **⟨big⟩** b"))) == "a ⟨big⟩ b")
        #expect(show(PageFormat.toggleWrap(PageFormat.bold, e("a ⟨**big**⟩ b"))) == "a ⟨big⟩ b")
        #expect(show(PageFormat.toggleWrap(PageFormat.italic, e("**⟨big⟩**"))) == "**_⟨big⟩_**")
        #expect(show(PageFormat.toggleWrap(PageFormat.strikethrough, e("⟨big ⟩"))) == "~~⟨big⟩~~ ")
    }

    @Test func wrapAtCaret() {
        #expect(show(PageFormat.toggleWrap(PageFormat.underline, e("a ‸"))) == "a ++‸++")
        #expect(show(PageFormat.toggleWrap(PageFormat.underline, e("a ++‸++"))) == "a ‸")
    }

    @Test func wrapSkipsMarkersAndSplitsLines() {
        #expect(show(PageFormat.toggleWrap(PageFormat.bold, e("⟨- one\n# two⟩"))) == "- **⟨one**\n# **two⟩**")
        #expect(show(PageFormat.toggleWrap(PageFormat.bold, e("⟨- ⟩x"))) == "⟨- ⟩x")
    }

    @Test func indentAndOutdent() {
        #expect(show(PageFormat.indent(e("⟨- a\n- b⟩"))) == "  ⟨- a\n  - b⟩")
        #expect(show(PageFormat.indent(e("   - a‸"), outdent: true)) == " - a‸")
        #expect(show(PageFormat.indent(e("- a‸"), outdent: true)) == "- a‸")
    }

    @Test func link() {
        #expect(show(PageFormat.link(e("see ⟨Release⟩ now"))) == "see [[Release]]‸ now")
        #expect(show(PageFormat.link(e("see ‸"))) == "see [[‸")
        #expect(show(PageFormat.link(e("⟨a|b⟩"))) == "a|b[[‸")
    }

    @Test func dividerAndCodeBlock() {
        #expect(show(PageFormat.divider(e("a‸\nb"))) == "a\n---\n‸b")
        #expect(show(PageFormat.divider(e("a‸"))) == "a\n---\n‸")
        #expect(show(PageFormat.divider(e("a\n‸"))) == "a\n---\n‸")
        #expect(show(PageFormat.codeBlock(e("‸"))) == "```\n‸\n```")
        #expect(show(PageFormat.codeBlock(e("⟨let x⟩"))) == "```\n⟨let x⟩\n```")
    }

    @Test func crlfLinesKeepTheirBreaks() {
        #expect(show(PageFormat.setStyle(.bullet, e("⟨a\r\nb⟩"))) == "- ⟨a\r\n- b⟩")
    }
}
