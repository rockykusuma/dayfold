import Foundation
import Testing
@testable import DayfoldCore

@Suite("Page markup")
struct PageMarkupTests {
    @Test func headings() {
        #expect(PageMarkup.blocks("# A\n### C") == [.heading(level: 1, text: "A"), .heading(level: 3, text: "C")])
        #expect(PageMarkup.blocks("#nospace") == [.paragraph("#nospace")])
        #expect(PageMarkup.blocks("####### seven") == [.paragraph("####### seven")])
    }

    @Test func bulletsAndIndent() {
        #expect(PageMarkup.blocks("- a\n  - b\n* c") == [
            .bullet(text: "a", indent: 0), .bullet(text: "b", indent: 1), .bullet(text: "c", indent: 0)])
    }

    @Test func checkboxes() {
        #expect(PageMarkup.blocks("- [ ] a\n- [X] b\n* [x] c") == [
            .checkbox(checked: false, text: "a", line: 0, indent: 0), .checkbox(checked: true, text: "b", line: 1, indent: 0),
            .checkbox(checked: true, text: "c", line: 2, indent: 0)])
    }

    @Test func nestedCheckboxes() {
        #expect(PageMarkup.blocks("- [ ] a\n  - [x] b\n    - [ ] c\n   - [ ] d") == [
            .checkbox(checked: false, text: "a", line: 0, indent: 0), .checkbox(checked: true, text: "b", line: 1, indent: 1),
            .checkbox(checked: false, text: "c", line: 2, indent: 2), .checkbox(checked: false, text: "d", line: 3, indent: 1)])
    }

    @Test func quoteAndDivider() {
        #expect(PageMarkup.blocks("> q\n---\n***\n___\n- ") == [
            .quote("q"), .divider, .divider, .divider, .bullet(text: "", indent: 0)])
    }

    @Test func codeFence() {
        #expect(PageMarkup.blocks("```\nlet x = 1\nprint(x)\n```\nafter") == [.code("let x = 1\nprint(x)"), .paragraph("after")])
        #expect(PageMarkup.blocks("```swift\nlet x = 1") == [.code("let x = 1")])
    }

    @Test func paragraphsJoin() {
        #expect(PageMarkup.blocks("a\nb\n\nc") == [.paragraph("a\nb"), .paragraph("c")])
    }

    @Test func crlfBody() {
        let lf = "# T\n- [ ] a\n- [ ] b\n\nend", crlf = lf.replacingOccurrences(of: "\n", with: "\r\n")
        #expect(PageMarkup.blocks(crlf) == PageMarkup.blocks(lf))
        #expect(PageMarkup.toggleCheckbox(in: "- [ ] a\r\n- [ ] b\r\n- [ ] c", line: 1) == "- [ ] a\r\n- [x] b\r\n- [ ] c")
    }

    @Test func toggleFlips() {
        #expect(PageMarkup.toggleCheckbox(in: "- [x] b\n- [ ] c", line: 0) == "- [ ] b\n- [ ] c")
        #expect(PageMarkup.toggleCheckbox(in: "a\n  * [ ] b\nc", line: 1) == "a\n  * [x] b\nc")
    }

    @Test func toggleOutOfRange() {
        let body = "- [ ] a\nplain"
        #expect(PageMarkup.toggleCheckbox(in: body, line: 99) == body)
        #expect(PageMarkup.toggleCheckbox(in: body, line: 1) == body)
        #expect(PageMarkup.toggleCheckbox(in: body, line: -1) == body)
    }
}
