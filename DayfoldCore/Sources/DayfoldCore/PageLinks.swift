import Foundation

/// `[[Wiki links]]` between note pages.
public enum PageLinks {
    public static let scheme = "dayfold-page"

    private struct Link { let range: Range<String.Index>; let target: String; let label: String? }

    /// Case/diacritic-insensitive, whitespace runs collapsed.
    public static func key(_ title: String) -> String { PeopleDirectory.normalize(title) }

    public static func titles(in body: String) -> [String] {
        var seen = Set<String>(), out: [String] = []
        for link in links(in: body) where seen.insert(key(link.target)).inserted { out.append(link.target) }
        return out
    }

    public static func resolve(_ title: String, in pages: [NotePage]) -> NotePage? {
        let k = key(title)
        guard !k.isEmpty else { return nil }
        return pages.filter { key($0.title) == k }.max { $0.updatedAt < $1.updatedAt }
    }

    public static func backlinks(to page: NotePage, in pages: [NotePage]) -> [NotePage] {
        let k = key(page.title)
        guard !k.isEmpty else { return [] }
        return pages
            .filter { $0.id != page.id && titles(in: $0.body).contains { key($0) == k } }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    /// Rewrites `[[old]]` / `[[old|label]]` in every body. Only changed pages get `updatedAt = now`.
    /// Titles must not contain `[`, `]`, `|` or newlines (the title field drops them), or the rewritten links won't parse.
    public static func rename(from old: String, to new: String, in pages: [NotePage], now: Date = Date()) {
        let oldKey = key(old), newTitle = new.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !oldKey.isEmpty, !newTitle.isEmpty, oldKey != key(newTitle) else { return }
        for page in pages {
            var body = page.body
            for link in links(in: body).reversed() where key(link.target) == oldKey {
                body.replaceSubrange(link.range, with: "[[" + newTitle + (link.label.map { "|" + $0 } ?? "") + "]]")
            }
            if body != page.body { page.body = body; page.updatedAt = now }
        }
    }

    /// `[[T]]` / `[[T|label]]` become `[text](dayfold-page:T%20…)` for `AttributedString(markdown:)`.
    public static func inlineMarkdown(_ text: String) -> String {
        var out = text
        for link in links(in: text).reversed() {
            let shown = (link.label ?? link.target).replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "[", with: "\\[").replacingOccurrences(of: "]", with: "\\]")
            let enc = link.target.addingPercentEncoding(withAllowedCharacters: allowed) ?? link.target
            out.replaceSubrange(link.range, with: "[\(shown)](\(scheme):\(enc))")
        }
        return out
    }

    /// The text after the last unclosed `[[`, if still on the same line.
    public static func completionToken(in text: String) -> String? {
        guard let open = text.range(of: "[[", options: .backwards) else { return nil }
        let rest = text[open.upperBound...]
        guard !rest.contains("]]"), !rest.contains(where: \.isNewline) else { return nil }
        return String(rest)
    }

    public static func title(from url: URL) -> String? {
        guard url.scheme == scheme else { return nil }
        return String(url.absoluteString.dropFirst(scheme.count + 1)).removingPercentEncoding
    }

    // MARK: Private

    // ponytail: parens are encoded too so they can't close the markdown link early.
    private static let allowed: CharacterSet = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "&#?%()"))

    private static func links(in body: String) -> [Link] {
        var out: [Link] = []
        var from = body.startIndex
        while let open = body.range(of: "[[", range: from..<body.endIndex),
              let close = body.range(of: "]]", range: open.upperBound..<body.endIndex) {
            let inner = body[open.upperBound..<close.lowerBound]
            if inner.contains("[[") || inner.contains(where: \.isNewline) { from = open.upperBound; continue }
            from = close.upperBound
            let parts = inner.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
            let target = parts[0].trimmingCharacters(in: .whitespaces)
            guard !target.isEmpty else { continue }
            let label = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : nil
            out.append(Link(range: open.lowerBound..<close.upperBound, target: target, label: label?.isEmpty == true ? nil : label))
        }
        return out
    }
}
