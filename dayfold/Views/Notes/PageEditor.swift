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
    /// The editor's own text and selection, kept together: it reports them separately and in either order, so a
    /// selection read against the model's older text was dropped (the first letter on an empty page put the caret before it).
    @State private var draft: String
    /// The editor's `TextSelection` (iOS 18 / macOS 15; `Any` so the view still builds for iOS 17).
    @State private var selection: Any?

    private enum Field { case title, body }

    init(page: NotePage, allPages: [NotePage], focusTitle: Bool) {
        self.page = page
        self.allPages = allPages
        self.focusTitle = focusTitle
        _title = State(initialValue: page.title)
        _draft = State(initialValue: page.body)
    }

    /// The selection in `Character` offsets of `draft`. Nil before iOS 18 / macOS 15 (no selection API): formats apply at the end.
    private var caret: Range<Int>? {
        guard #available(iOS 18, macOS 15, *), let s = selection as? TextSelection, case .selection(let r) = s.indices,
              r.upperBound <= draft.endIndex else { return nil }
        return draft.distance(from: draft.startIndex, to: r.lowerBound)..<draft.distance(from: draft.startIndex, to: r.upperBound)
    }

    /// Puts the editor's caret / selection at `r` in `draft`.
    private func setCaret(_ r: Range<Int>) {
        guard #available(iOS 18, macOS 15, *), r.upperBound <= draft.count else { return }
        let lo = draft.index(draft.startIndex, offsetBy: r.lowerBound)
        selection = TextSelection(range: lo..<draft.index(lo, offsetBy: r.count))
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
                .onChange(of: page.body) { _, stored in   // synced from another device: take it, drop the stale selection
                    if stored != draft { draft = stored; selection = nil }
                }
                .overlay(alignment: .topLeading) {
                    if draft.isEmpty {
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
            TextEditor(text: bodyContinuingLists, selection: Binding(get: { selection as? TextSelection }, set: { selection = $0 }))
        } else {
            TextEditor(text: bodyContinuingLists)
        }
    }

    /// The body, plus Notes' Return in a list: the next line gets the same marker; Return on an empty item ends the list.
    /// Decided on the next turn of the main queue: the editor reports the caret separately, in either order,
    /// and the caret is what says where the Return went.
    private var bodyContinuingLists: Binding<String> {
        Binding(get: { draft }, set: { new in
            let old = draft
            draft = new
            set(\.body, new)
            guard new.count == old.count + 1 else { return }
            DispatchQueue.main.async {
                guard draft == new, let c = caret, c.isEmpty, c.lowerBound > 0,
                      let edit = PageFormat.continueList(old: old, new: new, at: c.lowerBound - 1) else { return }
                apply(edit)
            }
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
        if caret?.isEmpty ?? true, let token = PageLinks.completionToken(in: String(draft.prefix(caret?.lowerBound ?? .max))) {
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
        let n = draft.count
        let sel = caret.map { $0.clamped(to: 0..<n) } ?? n..<n
        apply(op(PageEdit(text: draft, selection: sel)))
        focus = .body
    }

    private func apply(_ edit: PageEdit) {
        draft = edit.text
        set(\.body, edit.text)
        setCaret(edit.selection)
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

}
