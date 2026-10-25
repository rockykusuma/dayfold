import SwiftUI
import SwiftData
import DayfoldCore

/// A page to push. Hosts declare `.navigationDestination(for: PageRoute.self) { PageView(page: $0.page, startEditing: $0.startEditing) }`.
struct PageRoute: Hashable {
    let page: NotePage
    var startEditing = false

    static func == (a: PageRoute, b: PageRoute) -> Bool { a.page.id == b.page.id && a.startEditing == b.startEditing }
    func hash(into hasher: inout Hasher) {
        hasher.combine(page.id)
        hasher.combine(startEditing)
    }
}

/// One wiki page: rendered Markdown with links, subpages and backlinks; Edit switches to inline editing in place.
struct PageView: View {
    let page: NotePage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // ponytail: every page, for links, backlinks, rename and Move…. Fine for a personal wiki; add predicates if it grows huge.
    @Query private var allPages: [NotePage]
    @State private var editing: Bool
    @State private var focusTitle: Bool
    /// The title when edit mode began; a change is rewritten into every `[[link]]` on leaving.
    @State private var startTitle: String
    @State private var pushed: PageRoute?
    @State private var missingTitle: String?
    @State private var confirmingDelete = false
    @State private var moving = false
    @State private var toggles = 0

    init(page: NotePage, startEditing: Bool = false) {
        self.page = page
        _editing = State(initialValue: startEditing)
        _focusTitle = State(initialValue: startEditing)
        _startTitle = State(initialValue: page.title)
    }

    var body: some View {
        if page.isDeleted || page.modelContext == nil {
            Color.paper
        } else {
            content
        }
    }

    private var content: some View {
        // One container (not a Group): modifiers below, especially onDisappear, must not fire on the Edit/Done swap.
        VStack(spacing: 0) {
            if editing {
                PageEditor(page: page, allPages: allPages, focusTitle: focusTitle)
                    .frame(maxWidth: 720)
                    .frame(maxWidth: .infinity)
            } else {
                ScrollView { reading }
            }
        }
        .background(Color.paper)
        .navigationTitle(page.displayTitle)
        #if os(iOS)
        .toolbarTitleDisplayMode(.inline)
        #endif
        .toolbar { toolbar }
        .navigationDestination(item: $pushed) { PageView(page: $0.page, startEditing: $0.startEditing) }
        .sheet(isPresented: $moving) { MovePageSheet(page: page, allPages: allPages) }
        .confirmationDialog("Delete “\(page.displayTitle)”?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete Page", role: .destructive) {
                editing = false
                Pages.delete(page, in: context)
                dismiss()
            }
        } message: {
            Text("Its subpages move up a level.")
        }
        .confirmationDialog(missingTitle.map { "Create page “\($0)”?" } ?? "",
                            isPresented: Binding(get: { missingTitle != nil }, set: { if !$0 { missingTitle = nil } }),
                            titleVisibility: .visible, presenting: missingTitle) { title in
            Button("Create") { create(title) }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: toggles)
        // Back gesture, tab switch, window close: same as Done, but no pop (we're already leaving).
        .onDisappear { finishEditing(pop: false) }
    }

    // MARK: View mode

    private var reading: some View {
        let blocks = PageMarkup.blocks(page.body)
        let crumbs = Pages.breadcrumb(page)
        let children = page.sortedChildren.filter { !$0.isDeleted }
        let backlinks = PageLinks.backlinks(to: page, in: allPages)
        return VStack(alignment: .leading, spacing: 16) {
            if !crumbs.isEmpty { breadcrumb(crumbs) }
            Text(page.displayTitle)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .accessibilityAddTraits(.isHeader)
            if blocks.isEmpty {
                Text("Tap Edit to write.")
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(.secondary)
            } else {
                PageBlocksView(blocks: blocks, onToggle: toggle)
                    .environment(\.openURL, OpenURLAction { url in open(url) })
            }
            section("Subpages") {
                ForEach(children) { pageRow($0) }
                Button {
                    newSubpage()
                } label: {
                    Label("New Subpage", systemImage: "plus")
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tint)
            }
            if !backlinks.isEmpty {
                section("Linked from") { ForEach(backlinks) { pageRow($0) } }
            }
        }
        .padding()
        .frame(maxWidth: 720, alignment: .leading)
        .frame(maxWidth: .infinity)
    }

    private func breadcrumb(_ crumbs: [NotePage]) -> some View {
        HStack(spacing: 4) {
            ForEach(Array(crumbs.enumerated()), id: \.element.id) { i, crumb in
                if i > 0 { Text("›").foregroundStyle(.tertiary).accessibilityHidden(true) }
                Button(crumb.displayTitle) { pushed = PageRoute(page: crumb) }
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(minHeight: 44)
            }
        }
        .font(.subheadline)
    }

    private func section<Rows: View>(_ title: LocalizedStringKey, @ViewBuilder rows: () -> Rows) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 0, content: rows)
                .padding(.horizontal, 12)
                .background(Color.card, in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(.top, 8)
    }

    private func pageRow(_ p: NotePage) -> some View {
        Button { pushed = PageRoute(page: p) } label: {
            HStack {
                Text(p.displayTitle).font(.system(.body, design: .serif)).foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                page.isPinned.toggle()
            } label: {
                Label(page.isPinned ? "Unpin" : "Pin", systemImage: page.isPinned ? "pin.slash" : "pin")
            }
            ShareLink(item: "# \(page.displayTitle)\n\n\(page.body)") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Menu {
                Button { moving = true } label: { Label("Move…", systemImage: "folder") }
                Button(role: .destructive) { confirmingDelete = true } label: { Label("Delete Page", systemImage: "trash") }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
            Button(editing ? "Done" : "Edit") {
                editing ? finishEditing(pop: true) : beginEditing()
            }
        }
    }

    // MARK: Actions

    private func open(_ url: URL) -> OpenURLAction.Result {
        guard let title = PageLinks.title(from: url) else { return .systemAction }
        if let target = PageLinks.resolve(title, in: allPages) {
            pushed = PageRoute(page: target)
        } else {
            missingTitle = title
        }
        return .handled
    }

    /// Missing link target: a top-level page (easy to find; Move… can file it later), opened in edit mode.
    private func create(_ title: String) {
        let new = NotePage(title: title)
        context.insert(new)
        pushed = PageRoute(page: new, startEditing: true)
    }

    private func newSubpage() {
        let child = NotePage()
        context.insert(child)
        child.parent = page
        pushed = PageRoute(page: child, startEditing: true)
    }

    private func toggle(_ line: Int) {
        let body = PageMarkup.toggleCheckbox(in: page.body, line: line)
        guard body != page.body else { return }
        page.body = body
        page.updatedAt = Date()
        toggles += 1
    }

    private func beginEditing() {
        startTitle = page.title
        focusTitle = false
        withAnimation(reduceMotion ? nil : .snappy) { editing = true }
    }

    /// Done / leaving: rewrite links if the title changed, and remove the page if it's blank. Edits are already saved.
    /// `editing` is the once-only guard: Done clears it, so the later `onDisappear` does nothing.
    private func finishEditing(pop: Bool) {
        guard editing, !page.isDeleted, page.modelContext != nil else { return }
        withAnimation(reduceMotion ? nil : .snappy) { editing = false }
        PageLinks.rename(from: startTitle, to: page.title, in: allPages)
        if page.isBlank {
            Pages.delete(page, in: context)
            if pop { dismiss() }
        }
    }
}

/// "Top level" plus every page that isn't this one or below it, by breadcrumb path.
private struct MovePageSheet: View {
    let page: NotePage
    let allPages: [NotePage]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let excluded = Set([page.id] + Pages.descendants(of: page).map(\.id))
        let targets = allPages
            .filter { !excluded.contains($0.id) && !$0.isDeleted }
            .map { (page: $0, path: (Pages.breadcrumb($0) + [$0]).map(\.displayTitle).joined(separator: " › ")) }
            .sorted { $0.path.localizedStandardCompare($1.path) == .orderedAscending }
        NavigationStack {
            List {
                row(Text("Top level"), to: nil)
                ForEach(targets, id: \.page.id) { row(Text(verbatim: $0.path), to: $0.page) }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Move…")
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        #if os(macOS)
        .frame(minWidth: 380, minHeight: 440)
        #endif
    }

    private func row(_ label: Text, to target: NotePage?) -> some View {
        Button {
            Pages.move(page, to: target)
            dismiss()
        } label: {
            HStack {
                label.lineLimit(1).truncationMode(.middle).foregroundStyle(.primary)
                Spacer()
                if page.parent?.id == target?.id {
                    Image(systemName: "checkmark").foregroundStyle(.tint).accessibilityLabel("Current")
                }
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(Color.card)
    }
}

#if DEBUG
#Preview {
    let container = DemoData.container()
    let context = container.mainContext
    let onboarding = NotePage(title: "Onboarding", body: """
        # First week
        Read [[Release process]] and say hi to the **Platform** team.

        - [ ] Get a laptop
        - [x] Sign the forms
        - Ask about [[Missing page]]
          - nested bullet

        > Ask questions early.

        ```
        brew bundle
        ```
        ---
        See https://example.com
        """)
    let laptop = NotePage(title: "Laptop setup", body: "Install Xcode.")
    let release = NotePage(title: "Release process", body: "Steps live in [[Onboarding]].")
    [onboarding, laptop, release].forEach(context.insert)
    laptop.parent = onboarding
    return NavigationStack {
        PageView(page: onboarding)
            .navigationDestination(for: PageRoute.self) { PageView(page: $0.page, startEditing: $0.startEditing) }
    }
    .modelContainer(container)
}
#endif
