# Notes (Wiki) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Notes tab — a personal wiki of Markdown pages with `[[links]]`, backlinks, subpages, search and pinning.

**Architecture:** One additive SwiftData model (`NotePage`, self-referencing parent/children). All rules — tree operations, the Markdown block parser, checkbox toggling, wiki-link parsing/resolution/rename/backlinks, page search — live in `DayfoldCore` with tests. The app adds `NotesView` (fifth tab / Mac sidebar), `PageView` (rendered + inline edit), and a Notes section in Search.

**Tech Stack:** Swift 5 language mode, SwiftUI (iOS 17 / macOS 14), SwiftData + CloudKit, `AttributedString(markdown:)`, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-10-25-notes-wiki-design.md`

## Global Constraints

- iOS 17 / macOS 14, one codebase; Apple frameworks only (no Markdown packages); no new targets/entitlements.
- CloudKit: every stored property defaulted or optional; no `@Attribute(.unique)`; relationships optional with inverses; additive only.
- Logic in `DayfoldCore` with Swift Testing tests; views thin. Nothing from Notes on the Day page.
- Anti-goals: never discard an edit; deleting a page never deletes its subpages; renames rewrite links; blank untitled pages are removed when left.
- Copy (verbatim): tab / sidebar "Notes" (`books.vertical`); "Search notes"; sections "Pinned", "Pages", "Subpages", "Linked from"; "New Page", "New Subpage"; "Untitled"; "Edit" / "Done"; "Pin" / "Unpin"; "Share"; "Move…"; "Top level"; "Delete Page"; confirm "Delete “<Title>”?" with message "Its subpages move up a level."; "Create page “<Title>”?"; empty list "No pages yet" / "Tap + to start your wiki."; empty body "Tap Edit to write."; editor placeholders "Title", "Write in Markdown…"; insert row "Heading", "Bullet", "Checkbox", "Link"; Search section "Notes".
- Style: ink accent (`.tint`), `Color.paper`, `Color.card`, serif for titles/headings/empty states, 44pt targets, `.snappy`, Reduce Motion, Dynamic Type through accessibility sizes.
- Tests: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS` (focus `-only-testing:DayfoldCoreTests/<Suite>`). Never `swift test`.
- After every task that touches `dayfold/`, both builds pass:
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO`
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
- Commit trailers (every commit, exactly):
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_016KuWvS3f2pThajg7yChjq9`
- Core tests: `import Foundation`, `import SwiftData`, `import Testing`, `@testable import DayfoldCore`; `@MainActor` suites with `makeContainer()` (PeopleModelTests.swift — add `NotePage.self`).

## Review Focus

1. **Deleting a middle page in a three-level tree**: its children move to the grandparent; nothing below is lost. Test `deleteMiddleKeepsGrandchildren` in Task 1.
2. **Renaming with only a case change** ("release process" → "Release Process"): links untouched, no page's `updatedAt` bumped. Test `renameCaseOnlyNoop` in Task 2.
3. **Link titles with special characters** (`[[Q3 & Q4 plan #1]]`): rendered as a working link and resolved to the page. Test `inlineEscaping` in Task 2.
4. **A checkbox toggle against a body that changed underneath** (line index past the end, or the line is no longer a checkbox): body returned unchanged. Test `toggleOutOfRange` in Task 2.
5. **Windows line endings in a pasted body**: blocks parse the same as with `\n`, and toggling one checkbox leaves every other line byte-for-byte intact. Test `crlfBody` in Task 2.

---

### Task 1: `NotePage` model and tree rules

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/NotePage.swift` (model + `Pages`)
- Modify: `makeContainer()` in `DayfoldCore/Tests/DayfoldCoreTests/PeopleModelTests.swift`, `dayfold/AppStore.swift`, `dayfold/DemoData.swift` (schemas gain `NotePage.self`; keep everything else)
- Test: `DayfoldCore/Tests/DayfoldCoreTests/NotePageTests.swift`

**Interfaces:**
- Produces:
  ```swift
  @Model public final class NotePage {   // fields exactly as the spec's Data model section
      public init(title: String = "", body: String = "", isPinned: Bool = false, parent: NotePage? = nil,
                  createdAt: Date = Date(), updatedAt: Date = Date())
      public var displayTitle: String { get }; public var isBlank: Bool { get }; public var sortedChildren: [NotePage] { get } }
  public enum Pages {
      public static func delete(_ page: NotePage, in context: ModelContext)
      @discardableResult public static func move(_ page: NotePage, to newParent: NotePage?, now: Date = Date()) -> Bool
      public static func breadcrumb(_ page: NotePage) -> [NotePage]
      public static func descendants(of page: NotePage) -> [NotePage] }
  ```

- [ ] **Step 1: Write the failing tests** (`@Suite("Note pages") @MainActor struct NotePageTests`):
  - `helpers`: `displayTitle` "Untitled" for "  "; trimmed otherwise; `isBlank` true for empty title/body without children, false with a child; `sortedChildren` A–Z localized ("b", "A", "c" → "A","b","c").
  - `deleteReparentsToTop`: page with two children → after delete, both children have `parent == nil` and still exist.
  - `deleteMiddleKeepsGrandchildren`: A ▸ B ▸ C; delete B → C.parent === A; A.children contains C; 2 pages remain.
  - `moveRefusesCycles`: A ▸ B ▸ C; `move(A, to: C)` false and A.parent stays nil; `move(A, to: A)` false; `move(C, to: nil)` true and C top level; `updatedAt` set on success.
  - `breadcrumbRootFirst`: A ▸ B ▸ C → `breadcrumb(C).map(\.title) == ["A","B"]`; top-level → `[]`.
  - `breadcrumbCycleGuard`: force A.parent = B, B.parent = A directly (simulating sync) → `breadcrumb(A)` terminates with ≤ 50 items.
  - `descendants`: A ▸ (B ▸ C, D) → set of titles {B, C, D}.
- [ ] **Step 2: Run** `… -only-testing:DayfoldCoreTests/NotePageTests` — compile failure.
- [ ] **Step 3: Implement** `NotePage.swift`; add `NotePage.self` to the three schemas.
- [ ] **Step 4: Run the suite, the full core suite, both app builds.**
- [ ] **Step 5: Commit** `Notes: page model and tree rules`.

---

### Task 2: Markup, wiki links, page search

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/PageMarkup.swift`, `DayfoldCore/Sources/DayfoldCore/PageLinks.swift`
- Modify: `DayfoldCore/Sources/DayfoldCore/Search.swift` (add `pages`)
- Test: `DayfoldCore/Tests/DayfoldCoreTests/PageMarkupTests.swift`, `PageLinksTests.swift`, additions to `SearchTests.swift`

**Interfaces:**
- Consumes: `NotePage` (Task 1); `PeopleDirectory.normalize`.
- Produces:
  ```swift
  public enum PageBlock: Equatable { case heading(level: Int, text: String), paragraph(String), bullet(text: String, indent: Int),
      checkbox(checked: Bool, text: String, line: Int), quote(String), code(String), divider }
  public enum PageMarkup { public static func blocks(_ body: String) -> [PageBlock]
      public static func toggleCheckbox(in body: String, line: Int) -> String }
  public enum PageLinks {
      public static func titles(in body: String) -> [String]
      public static func key(_ title: String) -> String
      public static func resolve(_ title: String, in pages: [NotePage]) -> NotePage?
      public static func backlinks(to page: NotePage, in pages: [NotePage]) -> [NotePage]
      public static func rename(from old: String, to new: String, in pages: [NotePage], now: Date = Date())
      public static func inlineMarkdown(_ text: String) -> String
      public static func completionToken(in text: String) -> String?
      public static let scheme = "dayfold-page"
      public static func title(from url: URL) -> String?   // inverse of the link inlineMarkdown builds
  }
  extension Search { public static func pages(_ pages: [NotePage], query: String) -> [NotePage] }
  ```
  Rules exactly as the spec's `PageMarkup`, `PageLinks` and Search sections. Lines split with `split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)` so `\r\n` counts as one break; `toggleCheckbox` rebuilds the body by replacing only that line's `[ ]`/`[x]`, keeping every other line and the original separators. Link URLs: `dayfold-page:` + title percent-encoded with `.urlPathAllowed` minus `&#?%` (so `&`, `#`, spaces round-trip via `title(from:)`).

- [ ] **Step 1: Write the failing tests:**
  - `PageMarkupTests`: `headings` ("# A", "### C" → levels 1,3; "#nospace" is a paragraph); `bulletsAndIndent` ("- a", "  - b", "* c" → indents 0,1,0); `checkboxes` ("- [ ] a" unchecked line 0, "- [X] b" checked line 1, "* [x] c"); `quoteAndDivider` ("> q", "---" divider, "- " alone is a bullet with empty text); `codeFence` (``` lines → one `.code("let x = 1\nprint(x)")`; unclosed fence runs to end); `paragraphsJoin` ("a\nb\n\nc" → `.paragraph("a\nb")`, `.paragraph("c")`); `crlfBody` (same input with "\r\n" → same blocks; toggling line 1 of "- [ ] a\r\n- [ ] b\r\n- [ ] c" → "- [ ] a\r\n- [x] b\r\n- [ ] c"); `toggleFlips` ("- [x] b" → "- [ ] b", other lines untouched); `toggleOutOfRange` (line 99 or a non-checkbox line → body unchanged).
  - `PageLinksTests`: `titlesParse` ("See [[Release process]] and [[Onboarding|start here]] and [[release  process ]]" → ["Release process", "Onboarding"]); `resolveNormalizes` ("onbôarding" finds "Onboarding"; two pages titled "Plan" → newer `updatedAt`); `backlinksExcludeSelf` (A links B and itself, C links B → backlinks(B) == [newer of A,C first]; backlinks(A) excludes A); `renameRewrites` (bodies "[[Old]]", "[[old|label]]", "none" → "[[New]]", "[[New|label]]", unchanged; only changed pages get `updatedAt = now`); `renameCaseOnlyNoop` ("release process" → "Release Process": bodies and `updatedAt` unchanged); `inlineEscaping` (`inlineMarkdown("[[Q3 & Q4 plan #1]]")` produces a link whose URL's `title(from:)` == "Q3 & Q4 plan #1" and `AttributedString(markdown:)` parses it with one `.link`); `completionTokens` ("see [[Rel" → "Rel"; "see [[Rel]]" → nil; "[[" → ""; "a [[b]] [[c" → "c").
  - `SearchTests` additions: `pagesMatchWords` (title "Release process", body "Tag the build in Xcode" — "release xcode" matches, "release android" doesn't); `pagesTitleFirst` (one title match older than one body match → title match first); `pagesIgnoreTaskTokens` ("#x", "@a", "is:open" → `[]`).
- [ ] **Step 2: Run the new suites** — compile failures.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run the full core suite.**
- [ ] **Step 5: Commit** `Notes: Markdown blocks, wiki links, page search`.

---

### Task 3: `PageView` — rendered page and inline editing

**Files:**
- Create: `dayfold/Views/Notes/PageView.swift`, `dayfold/Views/Notes/PageBlocksView.swift` (renders `[PageBlock]`), `dayfold/Views/Notes/PageEditor.swift` (edit-mode fields + insert row + link suggestions)

**Interfaces:**
- Consumes: `NotePage`, `Pages` (Task 1); `PageMarkup`, `PageLinks` (Task 2).
- Produces: `struct PageView: View { init(page: NotePage, startEditing: Bool = false) }` — pushes linked pages via `NavigationLink(value: NotePage)` / a `navigationDestination(for: NotePage.self)` that the hosting stack declares (Task 4 declares it; for this task, declare it inside a `#Preview`/temporary host only).

- [ ] **Step 1: `PageBlocksView`** per the spec's Page section: headings serif (sizes by level), paragraphs/bullets/checkboxes/quotes with inline Markdown via `AttributedString(markdown: PageLinks.inlineMarkdown(text), options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))` (fall back to plain text if parsing throws); bullets indented 16pt per level; checkbox rows (○ / checkmark.circle.fill, 44pt) calling an `onToggle(line)` closure; quotes with a 3pt `.tint` leading rule; code in a monospaced `Color.card` rounded box with horizontal scroll; `Divider()`.
- [ ] **Step 2: Link handling** — `.environment(\.openURL, OpenURLAction { url in … })`: `dayfold-page:` URLs → `PageLinks.title(from:)` → `resolve` among all pages (`@Query`) → push; missing → confirmation "Create page “X”?" → insert a top-level `NotePage(title: X)` and push it with `startEditing: true`; other URLs → `.systemAction`.
- [ ] **Step 3: `PageEditor` / edit mode** per the spec: title `TextField` (serif, "Title"), body `TextEditor` (placeholder "Write in Markdown…"), insert row (Heading `# `, Bullet `- `, Checkbox `- [ ] `, Link `[[]]` — each appended on a new line), link suggestion strip when `PageLinks.completionToken(in: body)` is non-nil (titles whose key has the token's key as prefix, max 6, most recent first; tap replaces the partial with `Title]]`). Bind straight to the model; on each change set `updatedAt = now`. Use `.keyboardDismissButton()` (defined in `dayfold/Views/KeyboardDismiss.swift`).
- [ ] **Step 4: Leaving edit mode** (Done, `onDisappear`): if title changed since edit began → `PageLinks.rename(from: startTitle, to: page.title, in: allPages)`; if `page.isBlank` → `Pages.delete` and dismiss/pop.
- [ ] **Step 5: View mode layout** — breadcrumb row (ancestor titles separated by "›", tappable, middle-truncated), serif large title, blocks (or "Tap Edit to write."), then **Subpages** (rows + "New Subpage" → child page, push in edit mode) and **Linked from** (backlinks). Toolbar: Edit/Done; Pin/Unpin; `ShareLink(item: "# \(title)\n\n\(body)")` "Share"; menu: "Move…" (sheet listing "Top level" + all pages except itself and descendants, by breadcrumb path; uses `Pages.move`), "Delete Page" (confirmation copy from Global Constraints; `Pages.delete`, then pop). Checkbox taps write `PageMarkup.toggleCheckbox` + `updatedAt`.
- [ ] **Step 6: Build both platforms + full core suite.**
- [ ] **Step 7: Commit** `Notes: page view, Markdown rendering, inline editing`.

---

### Task 4: Notes tab, navigation, Search section

**Files:**
- Create: `dayfold/Views/Notes/NotesView.swift`
- Modify: `dayfold/Views/RootView.swift` (iPhone fifth tab "Notes" `books.vertical`, tag 4; Mac sidebar item "Notes" after Journal; DEBUG `-notes`, `-page <title prefix>`), `dayfold/Views/SearchView.swift` ("Notes" section after Journal, before tasks)

**Interfaces:**
- Consumes: `PageView(page:startEditing:)` (Task 3); `Search.pages` (Task 2); `Pages` (Task 1).

- [ ] **Step 1: `NotesView`** inside a `NavigationStack(path:)` with `.navigationDestination(for: NotePage.self) { PageView(page: $0) }` (new pages pushed with editing on — carry that via a small wrapper value or a `@State` set of "open in edit mode" ids). `.searchable(prompt: "Search notes")`: non-empty → `Search.pages` results with breadcrumb caption; empty → sections "Pinned" (pinned pages A–Z, any depth) and "Pages" (top-level A–Z) with rows per the spec (serif title, first body line preview, updated date caption, subpage count caption when > 0). Toolbar "+" "New Page" (Mac ⌥⌘P). Swipe/context: Pin/Unpin, Delete (confirmation copy). Empty state copy.
- [ ] **Step 2: Navigation** edits in RootView per Files. Existing tags/flags (`-search`, `-people`, `-journal`, `-week`, Review → Today, SearchRouter → Search) keep working; the iPhone Search tab tag stays 2, Journal 3, Notes 4.
- [ ] **Step 3: Search** — `@Query` pages; section "Notes" when `Search.pages` matches; rows = title + breadcrumb caption; tap pushes `PageView` (SearchView is inside a NavigationStack — add `.navigationDestination(for: NotePage.self)` there). "Nothing matches" shows only when tasks, journal and notes results are all empty.
- [ ] **Step 4: Build both platforms + full core suite; commit** `Notes: tab, list, search`.

---

### Task 5: Demo data, screenshots, docs

**Files:**
- Modify: `dayfold/DemoData.swift`, `CLAUDE.md`, `docs/spec.md`

- [ ] **Step 1: Demo pages** — "Release process" (headings, numbered-free steps as bullets, a code fence, a quote), "Team — Platform" (body links [[Release process]] and [[Onboarding]], pinned), "Onboarding" (three checkboxes, one checked) with subpage "Laptop setup" (body links [[Release process]]). Keep all existing demo content.
- [ ] **Step 2: Screenshot pass** — iPhone 16 Pro (`6EA53D1E-31C4-49B6-A404-84BE3F1D1104`) light + dark and SE (`F837D4E4-ADD4-4F3D-BB1A-544FB655C320`): `-demo -notes`, `-demo -notes -page Team`, `-demo -notes -page Onboarding`, `-demo -search release`. Simulator only via `xcrun simctl io <id> screenshot` (never the desktop) into the scratchpad `notes-shots/`. Fix what you see.
- [ ] **Step 3: Docs** — CLAUDE.md: Layout (`NotePage`, `PageMarkup`, `PageLinks` in Core; `Views/Notes/`), debug flags `-notes`, `-page`, State ("Notes (wiki) done"), CloudKit reminder lists `NotePage`, owner checks (editing on device, link tap → create page, Move…, rename rewrites links). `docs/spec.md` decisions: wiki links by title with rename rewriting; deleting reparents subpages; blank pages removed on leave; missing-link pages created top-level; insert row appends (no cursor API).
- [ ] **Step 4: Build both platforms + full core suite; commit** `Notes: demo pages, docs`.
