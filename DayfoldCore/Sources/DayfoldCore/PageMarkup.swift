import Foundation

public enum PageBlock: Equatable {
    case heading(level: Int, text: String)
    case paragraph(String)
    case bullet(text: String, indent: Int)
    /// `1. text` / `1) text`; the number is shown as typed.
    case numbered(number: Int, text: String, indent: Int)
    case checkbox(checked: Bool, text: String, line: Int, indent: Int)
    case quote(String)
    case code(String)
    case divider
}

/// Line-based Markdown subset for note pages. Inline styling is left to the view.
public enum PageMarkup {

    public static func blocks(_ body: String) -> [PageBlock] {
        var out: [PageBlock] = []
        var para: [String] = []
        var code: [String]?
        func flush() {
            if !para.isEmpty { out.append(.paragraph(para.joined(separator: "\n"))); para = [] }
        }
        let lines = body.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline).map(String.init)
        for (n, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if code != nil {
                if trimmed.hasPrefix("```") { out.append(.code(code!.joined(separator: "\n"))); code = nil }
                else { code!.append(line) }
                continue
            }
            if trimmed.hasPrefix("```") { flush(); code = []; continue }
            if trimmed.isEmpty { flush(); continue }
            if let h = heading(trimmed) { flush(); out.append(h); continue }
            if ["---", "***", "___"].contains(trimmed) { flush(); out.append(.divider); continue }
            if let box = checkbox(line) {
                flush(); out.append(.checkbox(checked: box.checked, text: box.text, line: n, indent: box.indent)); continue
            }
            if let item = bullet(line) { flush(); out.append(.bullet(text: item.text, indent: item.indent)); continue }
            if let item = numbered(line) {
                flush(); out.append(.numbered(number: item.number, text: item.text, indent: item.indent)); continue
            }
            if trimmed.hasPrefix("> ") { flush(); out.append(.quote(String(trimmed.dropFirst(2)))); continue }
            para.append(line)
        }
        if let code { out.append(.code(code.joined(separator: "\n"))) }
        flush()
        return out
    }

    /// Flips `[ ]` / `[x]` on that 0-based line only; anything else returns `body` unchanged.
    public static func toggleCheckbox(in body: String, line: Int) -> String {
        guard line >= 0 else { return body }
        var n = 0, start = body.startIndex
        var i = body.startIndex
        while true {
            if i == body.endIndex || body[i].isNewline {
                if n == line {
                    let text = String(body[start..<i])
                    guard let box = checkbox(text) else { return body }
                    let at = body.index(start, offsetBy: box.bracket + 1)
                    var out = body
                    out.replaceSubrange(at...at, with: box.checked ? " " : "x")
                    return out
                }
                if i == body.endIndex { return body }
                n += 1
                start = body.index(after: i)
            }
            if i == body.endIndex { return body }
            i = body.index(after: i)
        }
    }

    // MARK: Line parsing (also used by `PageFormat`)

    static func heading(_ s: String) -> PageBlock? {
        let hashes = s.prefix { $0 == "#" }.count
        guard (1...6).contains(hashes), s.dropFirst(hashes).first == " " else { return nil }
        return .heading(level: hashes, text: s.dropFirst(hashes).trimmingCharacters(in: .whitespaces))
    }

    /// Leading spaces and the text after a `- ` / `* ` marker.
    static func bullet(_ line: String) -> (indent: Int, text: String)? {
        let spaces = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(spaces)
        guard rest.hasPrefix("- ") || rest.hasPrefix("* ") else { return nil }
        return (spaces / 2, String(rest.dropFirst(2)))
    }

    /// `bracket` is the character offset of `[` within the line; `indent` as for bullets.
    static func checkbox(_ line: String) -> (checked: Bool, text: String, bracket: Int, indent: Int)? {
        guard let item = bullet(line) else { return nil }
        let t = item.text
        guard t.count >= 3, t.hasPrefix("["), t[t.index(t.startIndex, offsetBy: 2)] == "]" else { return nil }
        let mark = t[t.index(after: t.startIndex)]
        guard mark == " " || mark == "x" || mark == "X" else { return nil }
        let after = t.dropFirst(3)
        guard after.isEmpty || after.first == " " else { return nil }
        let spaces = line.prefix { $0 == " " }.count
        return (mark != " ", after.trimmingCharacters(in: .whitespaces), spaces + 2, item.indent)
    }

    /// Leading spaces, the number and the text after a `1. ` / `1) ` marker (up to 9 digits).
    static func numbered(_ line: String) -> (indent: Int, number: Int, text: String)? {
        let spaces = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(spaces)
        let digits = rest.prefix { $0.isASCII && $0.isNumber }
        guard (1...9).contains(digits.count), let n = Int(digits) else { return nil }
        let after = rest.dropFirst(digits.count)
        guard after.hasPrefix(". ") || after.hasPrefix(") ") else { return nil }
        return (spaces / 2, n, String(after.dropFirst(2)))
    }
}
