import SwiftUI
import SwiftData
import DayfoldCore

extension NotePage {
    /// "Parent › Child" ancestor titles, or nil for a top-level page.
    var pathCaption: String? {
        let crumbs = Pages.breadcrumb(self)
        return crumbs.isEmpty ? nil : crumbs.map(\.displayTitle).joined(separator: " › ")
    }
}

/// The Notes tab: pinned pages, then top-level pages; search switches to flat results with breadcrumbs.
struct NotesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Query private var pages: [NotePage]
    @State private var path: [PageRoute] = []
    @State private var query = ""
    @State private var deleting: NotePage?

    private var motion: Animation? { reduceMotion ? nil : .snappy }
    private func sorted(_ p: [NotePage]) -> [NotePage] {
        p.sorted { $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending }
    }

    var body: some View {
        NavigationStack(path: $path) {
            let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
            List {
                if !q.isEmpty {
                    let found = Search.pages(pages, query: q)
                    if found.isEmpty {
                        Text("Nothing matches “\(q)”")
                            .font(.system(.title3, design: .serif))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .listRowBackground(Color.clear)
                    }
                    ForEach(found) { row($0, showPath: true) }
                } else if pages.isEmpty {
                    emptyState
                } else {
                    let pinned = sorted(pages.filter(\.isPinned))
                    if !pinned.isEmpty {
                        Section { ForEach(pinned) { row($0) } } header: { header("Pinned") }
                    }
                    Section { ForEach(sorted(pages.filter { $0.parent == nil })) { row($0) } } header: { header("Pages") }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Notes")
            .searchable(text: $query, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: newPage) { Label("New Page", systemImage: "plus") }
                        .keyboardShortcut("p", modifiers: [.command, .option])
                        .help("New Page")
                }
            }
            .navigationDestination(for: PageRoute.self) { PageView(page: $0.page, startEditing: $0.startEditing) }
            .confirmationDialog("Delete “\(deleting?.displayTitle ?? "")”?",
                                isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } }),
                                titleVisibility: .visible, presenting: deleting) { page in
                Button("Delete Page", role: .destructive) { withAnimation(motion) { Pages.delete(page, in: context) } }
            } message: { _ in
                Text("Its subpages move up a level.")
            }
        }
        #if DEBUG
        // `-notes -page <title prefix>` opens the first matching page (screenshots can't tap).
        .task {
            let args = CommandLine.arguments
            guard let i = args.firstIndex(of: "-page"), i + 1 < args.count else { return }
            let prefix = args[i + 1].lowercased()
            if let p = sorted(pages).first(where: { $0.title.lowercased().hasPrefix(prefix) }) { path = [PageRoute(page: p)] }
        }
        #endif
    }

    private func header(_ title: String) -> some View {
        Text(title).font(.system(.headline, design: .serif)).foregroundStyle(Color.primary)
    }

    private func row(_ page: NotePage, showPath: Bool = false) -> some View {
        let preview = page.body.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }.first { !$0.isEmpty } ?? ""
        let subs = page.children?.count ?? 0
        return NavigationLink(value: PageRoute(page: page)) {
            VStack(alignment: .leading, spacing: 2) {
                Text(page.displayTitle).font(.system(.body, design: .serif, weight: .semibold))
                if showPath, let crumb = page.pathCaption {
                    Text(crumb).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                } else if !preview.isEmpty {
                    Text(preview).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                }
                HStack(spacing: 4) {
                    Text(page.updatedAt, format: .relative(presentation: .named))
                    if subs > 0 { Text("· \(subs) subpage\(subs == 1 ? "" : "s")") }
                }
                .font(.caption).foregroundStyle(.tertiary)
            }
            .frame(minHeight: 44, alignment: .leading)
        }
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            Button { togglePin(page) } label: {
                Label(page.isPinned ? "Unpin" : "Pin", systemImage: page.isPinned ? "pin.slash" : "pin")
            }
            .tint(.accentColor)
        }
        .swipeActions(edge: .trailing) {
            // Not `role: .destructive`: the row stays until the confirmation says Delete.
            Button { deleting = page } label: { Label("Delete Page", systemImage: "trash") }.tint(.red)
        }
        .contextMenu {
            Button(page.isPinned ? "Unpin" : "Pin", systemImage: page.isPinned ? "pin.slash" : "pin") { togglePin(page) }
            Divider()
            Button("Delete Page", systemImage: "trash", role: .destructive) { deleting = page }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "books.vertical").font(.largeTitle).foregroundStyle(.tertiary)
            Text("No pages yet").font(.system(.title3, design: .serif, weight: .semibold))
            Text("Tap + to start your wiki.").font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func togglePin(_ page: NotePage) {
        withAnimation(motion) { page.isPinned.toggle() }
    }

    private func newPage() {
        let page = NotePage()
        context.insert(page)
        path.append(PageRoute(page: page, startEditing: true))
    }
}
