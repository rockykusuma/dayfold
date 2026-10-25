import SwiftUI
import SwiftData
import DayfoldCore

/// Edit mode for a page: writes straight to the model (autosave) and bumps `updatedAt` on every change.
struct PageEditor: View {
    let page: NotePage
    let allPages: [NotePage]
    let focusTitle: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var focus: Field?
    /// Draft for the title field, so a dropped character never stays visible; the model gets every real change.
    @State private var title: String
    /// The body selection in `Character` offsets. Stays nil before iOS 18 / macOS 15 (no selection API): formats apply at the end.
    @State private var caret: Range<Int>?

    private enum Field { case title, body }

    init(page: NotePage, allPages: [NotePage], focusTitle: Bool) {
        self.page = page
        self.allPages = allPages
        self.focusTitle = focusTitle
        _title = State(initialValue: page.title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .textFieldStyle(.plain)
                .focused($focus, equals: .title)
                .submitLabel(.next)
                .onSubmit { focus = .body }
                // `[`, `]`, `|` and newlines would break `[[links]]` to this page, so they're dropped as typed or pasted.
                .onChange(of: title) { _, new in
                    let clean = new.filter { !"[]|".contains($0) && !$0.isNewline }
                    if clean != new { title = clean }
                    set(\.title, clean)
                }
                .onChange(of: page.title) { _, stored in if stored != title { title = stored } }   // synced from elsewhere
            if hasDuplicateTitle {
                Text("Another page has this title")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            formatBar
            suggestionStrip
            bodyEditor
                .focused($focus, equals: .body)
                .scrollContentBackground(.hidden)
                .overlay(alignment: .topLeading) {
                    if page.body.isEmpty {
                        Text("Write in Markdown…")
                            .foregroundStyle(.tertiary)
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Write in Markdown…")
                .padding(8)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .keyboardDismissButton()
        .task { focus = focusTitle ? .title : .body }   // after the push/toggle has landed
    }

    @ViewBuilder
    private var bodyEditor: some View {
        if #available(iOS 18, macOS 15, *) {
            TextEditor(text: field(\.body), selection: textSelection)
        } else {
            TextEditor(text: field(\.body))
        }
    }

    /// `caret` as the editor's selection; multi-selections (Mac ⌘-drag) are ignored.
    @available(iOS 18, macOS 15, *)
    private var textSelection: Binding<TextSelection?> {
        Binding(get: {
            let t = page.body
            guard let r = caret, r.upperBound <= t.count else { return nil }
            let lo = t.index(t.startIndex, offsetBy: r.lowerBound)
            return TextSelection(range: lo..<t.index(lo, offsetBy: r.count))
        }, set: { new in
            let t = page.body
            guard let new, case .selection(let r) = new.indices, r.upperBound <= t.endIndex else { return }
            caret = t.distance(from: t.startIndex, to: r.lowerBound)..<t.distance(from: t.startIndex, to: r.upperBound)
        })
    }

    /// Apple Notes' formatting, written as Markdown: text styles, B/I/U/S, lists, quote, indent, link, divider.
    private var formatBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                Menu {
                    style("Title", "textformat.size.larger", .title)
                    style("Heading", "textformat.size", .heading)
                    style("Subheading", "textformat.size.smaller", .subheading)
                    style("Body", "text.alignleft", .body)
                    Button { format(PageFormat.codeBlock) } label: { Label("Monostyled", systemImage: "chevron.left.forwardslash.chevron.right") }
                } label: {
                    tool("Text Style", "textformat")
                }
                .menuIndicator(.hidden)
                wrap("Bold", "bold", PageFormat.bold)
                wrap("Italic", "italic", PageFormat.italic)
                wrap("Underline", "underline", PageFormat.underline)
                wrap("Strikethrough", "strikethrough", PageFormat.strikethrough)
                Divider().frame(height: 24).padding(.horizontal, 4)
                button("Bulleted List", "list.bullet") { PageFormat.setStyle(.bullet, $0) }
                button("Numbered List", "list.number") { PageFormat.setStyle(.numbered, $0) }
                button("Checklist", "checklist") { PageFormat.setStyle(.checklist, $0) }
                button("Block Quote", "text.quote") { PageFormat.setStyle(.quote, $0) }
                button("Decrease Indent", "decrease.indent") { PageFormat.indent($0, outdent: true) }
                button("Increase Indent", "increase.indent") { PageFormat.indent($0) }
                Divider().frame(height: 24).padding(.horizontal, 4)
                button("Link", "link", PageFormat.link)   // an open `[[` shows the title suggestions
                button("Divider", "minus", PageFormat.divider)
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 4)
        }
        .background(Color.card, in: RoundedRectangle(cornerRadius: 10))
    }

    private func tool(_ name: LocalizedStringKey, _ symbol: String) -> some View {
        Label(name, systemImage: symbol)
            .labelStyle(.iconOnly)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }

    private func button(_ name: LocalizedStringKey, _ symbol: String, _ op: @escaping (PageEdit) -> PageEdit) -> some View {
        Button { format(op) } label: { tool(name, symbol) }.help(Text(name))
    }

    private func wrap(_ name: LocalizedStringKey, _ symbol: String, _ marker: String) -> some View {
        button(name, symbol) { PageFormat.toggleWrap(marker, $0) }
    }

    private func style(_ name: LocalizedStringKey, _ symbol: String, _ s: PageFormat.LineStyle) -> some View {
        Button { format { PageFormat.setStyle(s, $0) } } label: { Label(name, systemImage: symbol) }
    }

    @ViewBuilder
    private var suggestionStrip: some View {
        // Only while the caret sits right after an open `[[` (or, without a caret, at the end).
        if caret?.isEmpty ?? true, let token = PageLinks.completionToken(in: String(page.body.prefix(caret?.lowerBound ?? .max))) {
            let titles = suggestions(for: token)
            if !titles.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(titles, id: \.self) { title in
                            Button {
                                withAnimation(reduceMotion ? nil : .snappy) { complete(token, with: title) }
                            } label: {
                                Text(verbatim: title)
                                    .font(.system(.subheadline, design: .serif))
                                    .lineLimit(1)
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.bordered)
                            .tint(.accentColor)
                        }
                    }
                }
            }
        }
    }

    /// Other pages whose key starts with the partial's key, newest first, at most 6, one per key.
    private func suggestions(for token: String) -> [String] {
        let prefix = PageLinks.key(token)
        var seen = Set<String>()
        return allPages
            .filter { $0.id != page.id && !$0.isDeleted }
            .sorted { $0.updatedAt > $1.updatedAt }
            .compactMap { p -> String? in
                let k = PageLinks.key(p.title)
                guard !k.isEmpty, k.hasPrefix(prefix), seen.insert(k).inserted else { return nil }
                return p.title.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .prefix(6)
            .map { $0 }
    }

    private func complete(_ token: String, with title: String) {
        format { e in
            var c = Array(e.text)
            let start = e.selection.lowerBound - token.count
            c.replaceSubrange(start..<e.selection.lowerBound, with: Array(title + "]]"))
            let end = start + title.count + 2
            return PageEdit(text: String(c), selection: end..<end)
        }
    }

    /// Runs a `PageFormat` edit on the body at the caret (the end when unknown) and puts the caret where it says.
    private func format(_ op: (PageEdit) -> PageEdit) {
        let n = page.body.count
        let sel = caret.map { $0.clamped(to: 0..<n) } ?? n..<n
        let out = op(PageEdit(text: page.body, selection: sel))
        set(\.body, out.text)
        caret = out.selection
        focus = .body
    }

    private func set(_ key: ReferenceWritableKeyPath<NotePage, String>, _ value: String) {
        guard page[keyPath: key] != value else { return }
        page[keyPath: key] = value
        page.updatedAt = Date()
    }

    private var hasDuplicateTitle: Bool {
        let k = PageLinks.key(page.title)
        return !k.isEmpty && allPages.contains { $0.id != page.id && !$0.isDeleted && PageLinks.key($0.title) == k }
    }

    private func field(_ key: ReferenceWritableKeyPath<NotePage, String>) -> Binding<String> {
        Binding(get: { page[keyPath: key] }, set: { set(key, $0) })
    }
}
