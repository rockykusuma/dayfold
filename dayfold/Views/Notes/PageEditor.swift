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

    private enum Field { case title, body }

    private static let inserts: [(label: LocalizedStringKey, symbol: String, text: String)] = [
        ("Heading", "number", "# "),
        ("Bullet", "list.bullet", "- "),
        ("Checkbox", "checklist", "- [ ] "),
        ("Link", "link", "[[]]"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: field(\.title))
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .textFieldStyle(.plain)
                .focused($focus, equals: .title)
                .submitLabel(.next)
                .onSubmit { focus = .body }
            insertRow
            suggestionStrip
            TextEditor(text: field(\.body))
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

    private var insertRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.inserts, id: \.text) { item in
                    Button { append(item.text) } label: {
                        Label(item.label, systemImage: item.symbol)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    @ViewBuilder
    private var suggestionStrip: some View {
        if let token = PageLinks.completionToken(in: page.body) {
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
                .transition(.opacity)
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
        set(\.body, String(page.body.dropLast(token.count)) + title + "]]")
    }

    /// Cursor placement isn't available for `TextEditor` on iOS 17, so inserts go on a new line at the end.
    private func append(_ text: String) {
        var body = page.body
        if let last = body.last, !last.isNewline { body += "\n" }
        set(\.body, body + text)
        focus = .body
    }

    private func set(_ key: ReferenceWritableKeyPath<NotePage, String>, _ value: String) {
        guard page[keyPath: key] != value else { return }
        page[keyPath: key] = value
        page.updatedAt = Date()
    }

    private func field(_ key: ReferenceWritableKeyPath<NotePage, String>) -> Binding<String> {
        Binding(get: { page[keyPath: key] }, set: { set(key, $0) })
    }
}
