import Foundation

/// A page body and its selection, in `Character` offsets.
public struct PageEdit: Equatable {
    public var text: String
    public var selection: Range<Int>

    public init(text: String, selection: Range<Int>) {
        self.text = text
        self.selection = selection
    }
}

/// Notes-style formatting for the selection of a page body, written as Markdown that `PageMarkup` renders.
public enum PageFormat {

    public enum LineStyle: Equatable {
        case title, heading, subheading, body, bullet, numbered, checklist, quote
    }

    /// Inline markers for `toggleWrap`. Italic is `_` so it never collides with bold's `**`; underline is `++`.
    public static let bold = "**", italic = "_", strikethrough = "~~", underline = "++", code = "`"

    /// Applies a line style to every line the selection touches. If they all have it already, they go back to body text.
    /// List styles keep the line's indent; numbered lines count up (continuing a numbered line just above).
    public static func setStyle(_ style: LineStyle, _ edit: PageEdit) -> PageEdit {
        let c = Array(edit.text)
        let ls = lines(c)
        let touched = touchedLines(ls, edit.selection)
        let parsed = touched.map { parse(String(c[ls[$0]])) }
        let target: LineStyle = style != .body && parsed.allSatisfy({ $0.style == style }) ? .body : style
        var n = 1
        if let first = touched.first, first > 0, let prev = PageMarkup.numbered(String(c[ls[first - 1]])) { n = prev.number + 1 }
        return rewrite(edit, lines: ls, touched: touched) { i, line in
            let p = parsed[i]
            if p.style == target && target != .numbered { return (line, p.contentStart, p.contentStart) }
            let indent = String(repeating: " ", count: p.indent)
            let prefix: String
            switch target {
            case .title: prefix = "# "
            case .heading: prefix = "## "
            case .subheading: prefix = "### "
            case .body: prefix = ""
            case .quote: prefix = "> "
            case .bullet: prefix = indent + "- "
            case .checklist: prefix = indent + "- [ ] "
            case .numbered: prefix = indent + "\(n). "; n += 1
            }
            return (prefix + String(line.dropFirst(p.contentStart)), p.contentStart, prefix.count)
        }
    }

    /// Wraps the selection in `marker` (per line, after any list or heading marker, trimmed of spaces), or unwraps it when
    /// it is already wrapped, inside or just outside the selection. A caret inserts an empty pair and sits inside it.
    public static func toggleWrap(_ marker: String, _ edit: PageEdit) -> PageEdit {
        var c = Array(edit.text)
        let m = Array(marker), k = m.count
        let lo = edit.selection.lowerBound, hi = edit.selection.upperBound
        func has(_ at: Int) -> Bool { at >= 0 && at + k <= c.count && Array(c[at..<at + k]) == m }
        if lo == hi {
            if has(lo - k), has(lo) {
                c.removeSubrange(lo - k..<lo + k)
                return PageEdit(text: String(c), selection: lo - k..<lo - k)
            }
            c.insert(contentsOf: m + m, at: lo)
            return PageEdit(text: String(c), selection: lo + k..<lo + k)
        }
        let ls = lines(c)
        let segments: [Range<Int>] = touchedLines(ls, edit.selection).compactMap { i in
            let r = ls[i]
            var a = max(lo, r.lowerBound + parse(String(c[r])).contentStart), b = min(hi, r.upperBound)
            while a < b, c[a].isWhitespace { a += 1 }
            while b > a, c[b - 1].isWhitespace { b -= 1 }
            return a < b ? a..<b : nil
        }
        guard let first = segments.first else { return edit }
        var newFirst = first, shift = 0, lastEnd = 0
        for (j, s) in segments.enumerated().reversed() {
            let new: Range<Int>, grew: Int
            if s.count >= 2 * k, has(s.lowerBound), has(s.upperBound - k) {
                c.removeSubrange(s.upperBound - k..<s.upperBound)
                c.removeSubrange(s.lowerBound..<s.lowerBound + k)
                new = s.lowerBound..<s.upperBound - 2 * k; grew = -2 * k
            } else if has(s.lowerBound - k), has(s.upperBound) {
                c.removeSubrange(s.upperBound..<s.upperBound + k)
                c.removeSubrange(s.lowerBound - k..<s.lowerBound)
                new = s.lowerBound - k..<s.upperBound - k; grew = -2 * k
            } else {
                c.insert(contentsOf: m, at: s.upperBound)
                c.insert(contentsOf: m, at: s.lowerBound)
                new = s.lowerBound + k..<s.upperBound + k; grew = 2 * k
            }
            if j == segments.count - 1 { lastEnd = new.upperBound } else { shift += grew }
            if j == 0 { newFirst = new }
        }
        return PageEdit(text: String(c), selection: newFirst.lowerBound..<lastEnd + shift)
    }

    /// Adds two leading spaces to every touched line, or (outdent) removes up to two.
    public static func indent(_ edit: PageEdit, outdent: Bool = false) -> PageEdit {
        let ls = lines(Array(edit.text))
        return rewrite(edit, lines: ls, touched: touchedLines(ls, edit.selection)) { _, line in
            if !outdent { return ("  " + line, 0, 2) }
            let drop = min(2, line.prefix { $0 == " " }.count)
            return (String(line.dropFirst(drop)), drop, 0)
        }
    }

    /// A selection on one line becomes `[[selection]]`; otherwise `[[` goes in at the caret for the title suggestions.
    public static func link(_ edit: PageEdit) -> PageEdit {
        var c = Array(edit.text)
        let sel = c[edit.selection]
        if !sel.isEmpty, !sel.contains(where: { $0.isNewline || "[]|".contains($0) }) {
            c.replaceSubrange(edit.selection, with: Array("[[") + sel + Array("]]"))
            let end = edit.selection.upperBound + 4
            return PageEdit(text: String(c), selection: end..<end)
        }
        let at = edit.selection.upperBound
        c.insert(contentsOf: "[[", at: at)
        return PageEdit(text: String(c), selection: at + 2..<at + 2)
    }

    /// `---` on its own line after the caret's line (or in place of a blank line); the caret moves to the line after it.
    public static func divider(_ edit: PageEdit) -> PageEdit {
        var c = Array(edit.text)
        let ls = lines(c)
        let r = ls[lineIndex(ls, edit.selection.upperBound)]
        var at: Int
        if c[r].allSatisfy(\.isWhitespace) {
            c.replaceSubrange(r, with: "---")
            at = r.lowerBound + 3
        } else {
            c.insert(contentsOf: "\n---", at: r.upperBound)
            at = r.upperBound + 4
        }
        if at == c.count { c.append("\n") }
        at += 1
        return PageEdit(text: String(c), selection: at..<at)
    }

    /// Fences the touched lines with ```; on a blank line, an empty block with the caret inside.
    public static func codeBlock(_ edit: PageEdit) -> PageEdit {
        var c = Array(edit.text)
        let ls = lines(c)
        let touched = touchedLines(ls, edit.selection)
        let top = ls[touched.first!], bottom = ls[touched.last!]
        if edit.selection.isEmpty, c[top].allSatisfy(\.isWhitespace) {
            c.replaceSubrange(top, with: "```\n\n```")
            return PageEdit(text: String(c), selection: top.lowerBound + 4..<top.lowerBound + 4)
        }
        c.insert(contentsOf: "\n```", at: bottom.upperBound)
        c.insert(contentsOf: "```\n", at: top.lowerBound)
        let hi = edit.selection.upperBound + (edit.selection.upperBound > bottom.upperBound ? 8 : 4)
        return PageEdit(text: String(c), selection: edit.selection.lowerBound + 4..<hi)
    }

    /// Return on a list line: `new` is `old` with one line break typed at `at` (the caret says where: next to another
    /// break the text alone can't). The new line gets the same marker (numbered +1, checklist unchecked, quote continues);
    /// Return on an empty item, with nothing after the caret, ends the list instead. nil when the change is anything else.
    public static func continueList(old: String, new: String, at: Int) -> PageEdit? {
        let o = Array(old), n = Array(new)
        guard n.count == o.count + 1, (0..<n.count).contains(at), n[at].isNewline,
              Array(n[..<at]) == Array(o[..<at]), Array(n[(at + 1)...]) == Array(o[at...]) else { return nil }
        let start = o[..<at].lastIndex(where: \.isNewline).map { $0 + 1 } ?? 0
        let line = String(o[start..<at])
        let rest = o[at...].prefix { !$0.isNewline }
        let spaces = String(repeating: " ", count: line.prefix { $0 == " " }.count)
        let marker: String, text: String
        if let box = PageMarkup.checkbox(line) {
            (marker, text) = (spaces + "- [ ] ", box.text)
        } else if let item = PageMarkup.bullet(line) {
            (marker, text) = (spaces + String(line.dropFirst(spaces.count).prefix(2)), item.text)
        } else if let item = PageMarkup.numbered(line) {
            let delimiter = line.dropFirst(spaces.count + String(item.number).count).prefix(1)
            (marker, text) = (spaces + "\(item.number + 1)\(delimiter) ", item.text)
        } else if line.dropFirst(spaces.count).hasPrefix("> ") {
            (marker, text) = (spaces + "> ", String(line.dropFirst(spaces.count + 2)))
        } else {
            return nil
        }
        if text.trimmingCharacters(in: .whitespaces).isEmpty, rest.isEmpty {
            var out = o
            out.removeSubrange(start..<at)
            return PageEdit(text: String(out), selection: start..<start)
        }
        var out = n
        out.insert(contentsOf: marker, at: at + 1)
        let caret = at + 1 + marker.count
        return PageEdit(text: String(out), selection: caret..<caret)
    }

    // MARK: Lines

    /// The line's style, its leading spaces, and where its text starts after any marker.
    static func parse(_ line: String) -> (style: LineStyle, indent: Int, contentStart: Int) {
        let spaces = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(spaces)
        if case .heading(let level, _)? = PageMarkup.heading(String(rest)) {
            return (level == 1 ? .title : level == 2 ? .heading : .subheading, 0, spaces + level + 1)
        }
        if let box = PageMarkup.checkbox(line) {
            return (.checklist, spaces, min(line.count, box.bracket + 4))
        }
        if PageMarkup.bullet(line) != nil { return (.bullet, spaces, spaces + 2) }
        if let item = PageMarkup.numbered(line) { return (.numbered, spaces, spaces + String(item.number).count + 2) }
        if rest.hasPrefix("> ") { return (.quote, 0, spaces + 2) }
        return (.body, spaces, spaces)
    }

    /// Character ranges of each line, without its line break (a `\r\n` is one `Character`).
    private static func lines(_ c: [Character]) -> [Range<Int>] {
        var out: [Range<Int>] = [], start = 0
        for (i, ch) in c.enumerated() where ch.isNewline {
            out.append(start..<i)
            start = i + 1
        }
        out.append(start..<c.count)
        return out
    }

    private static func lineIndex(_ ls: [Range<Int>], _ p: Int) -> Int {
        ls.firstIndex { p <= $0.upperBound } ?? ls.count - 1
    }

    /// A selection ending right after a line break doesn't touch the next line.
    private static func touchedLines(_ ls: [Range<Int>], _ sel: Range<Int>) -> ClosedRange<Int> {
        lineIndex(ls, sel.lowerBound)...lineIndex(ls, sel.isEmpty ? sel.upperBound : sel.upperBound - 1)
    }

    /// Replaces each touched line with `transform`'s line and maps the selection: a position keeps its offset into the
    /// line's text (after `oldStart` → after `newStart`), and one inside the old marker lands at the new text's start.
    private static func rewrite(_ edit: PageEdit, lines ls: [Range<Int>], touched: ClosedRange<Int>,
                                transform: (Int, String) -> (line: String, oldStart: Int, newStart: Int)) -> PageEdit {
        let c = Array(edit.text)
        var out = Array(c[..<ls[touched.lowerBound].lowerBound])
        var delta = 0
        var map: [(old: Range<Int>, newLower: Int, newCount: Int, oldStart: Int, newStart: Int)] = []
        for (i, li) in touched.enumerated() {
            let r = ls[li]
            if i > 0 { out.append(c[r.lowerBound - 1]) }   // the line break between touched lines
            let t = transform(i, String(c[r]))
            map.append((r, out.count, t.line.count, t.oldStart, t.newStart))
            out += Array(t.line)
            delta = out.count - r.upperBound
        }
        out += c[ls[touched.upperBound].upperBound...]
        func move(_ p: Int) -> Int {
            guard let m = map.first(where: { $0.old.contains(p) || $0.old.upperBound == p }) else {
                return p < map[0].old.lowerBound ? p : p + delta
            }
            return min(m.newLower + m.newStart + max(0, p - m.old.lowerBound - m.oldStart), m.newLower + m.newCount)
        }
        let lo = move(edit.selection.lowerBound)
        return PageEdit(text: String(out), selection: lo..<max(lo, move(edit.selection.upperBound)))
    }
}
