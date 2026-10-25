# Notes (wiki) — design

Date: 2026-10-25 · Status: owner asked for "a note section where I really want to note down important things
for future references. Kind of a like a wiki also", then "skip the questions, just start". Every decision
below is Claude's call and open to override. Owner constraint: the Journal stays its own tab and nothing
reference-like goes on the Day page.

## Why

The daily log is for what's happening now; the journal is for how it went. Neither is a good home for
things you need again later — how the release process works, what a teammate prefers, the steps to set up
a laptop, a list of contacts at a vendor. Those need a stable place, a title you can find, and links
between them, like a small personal wiki.

## Goals

1. **Notes tab** — a fifth tab (Mac: sidebar item) listing pages, pinned first.
2. **Pages** — a title and a body written in light Markdown (headings, bullets, checkboxes, quotes, code,
   bold/italic/links), shown formatted; edit in place, saved as you type.
3. **Wiki links** — `[[Page title]]` links pages together; "Linked from" shows backlinks; renaming a page
   updates links to it; tapping a link to a page that doesn't exist offers to create it.
4. **Structure** — optional subpages (any depth), a breadcrumb, Move to another parent.
5. **Find** — search inside Notes, and pages appear in the main Search tab.

## Non-goals

Photos/attachments, tables, rich-text toolbar beyond a small insert row, templates, page history/versions,
collaboration/sharing beyond the system share sheet (plain Markdown), locking (the journal lock doesn't
apply), linking pages to tasks/people, capturing into a page from other screens, export files.

## Anti-goals

- Losing writing: no edit is ever discarded; deleting a page never deletes its subpages; renames never
  break links silently.
- A blank page cluttering the list: an untitled, empty page is removed when you leave it.
- Anything wiki-ish appearing on the Day page.
- Breaking CloudKit sync rules.

## Constraints

As the app: iOS 17 / macOS 14 one codebase; SwiftData + CloudKit (defaults/optionals, no unique,
optional inverse relationships, additive schema); logic in `DayfoldCore` with Swift Testing tests; views
thin; Apple frameworks only (no Markdown packages — render with `AttributedString(markdown:)` for inline
styles plus our own block parser); calm style (ink, paper, card, serif titles, 44pt, Dynamic Type,
Reduce Motion).

## Data model (DayfoldCore) — additive

`NotePage` (@Model): `id: UUID = UUID()`, `title: String = ""`, `body: String = ""`,
`isPinned: Bool = false`, `createdAt: Date = Date()`, `updatedAt: Date = Date()`,
`parent: NotePage?`, `children: [NotePage]?` (`@Relationship(deleteRule: .nullify, inverse: \NotePage.parent)`).
Helpers: `displayTitle` (title trimmed, or "Untitled"), `isBlank` (title and body trimmed empty, no
children), `sortedChildren` (by `displayTitle`, localized).

**Before TestFlight: deploy `NotePage` to the CloudKit production schema.**

## Rules (DayfoldCore, tested)

### `Pages`
- `delete(_ page:, in:)` — reparent each child to `page.parent` (keeps subpages), then delete.
- `move(_ page:, to newParent: NotePage?)` — refuses (returns false) when `newParent` is the page or one of
  its descendants; else sets `parent`, `updatedAt`.
- `breadcrumb(_ page:) -> [NotePage]` — ancestors, root first (guards against cycles from sync: stop at 50).
- `descendants(of:) -> [NotePage]`.

### `PageMarkup`
`blocks(_ body: String) -> [PageBlock]`, line-based:
- `# `…`###### ` → `.heading(level, text)`; `- ` / `* ` → `.bullet(text, indent)` (indent = leading
  spaces / 2); `- [ ] ` / `- [x] ` (any case x, also `* [ ]`) → `.checkbox(checked, text, line)`
  (line = 0-based source line index); `> ` → `.quote(text)`; fenced ``` … ``` → `.code(text)` (unclosed
  fence runs to end); `---` / `***` alone → `.divider`; blank line separates paragraphs; consecutive
  non-blank other lines join with "\n" into `.paragraph(text)`.
- `toggleCheckbox(in body:, line:) -> String` — flips `[ ]`↔`[x]` on that line only; unchanged otherwise.
- Inline text (headings, bullets, checkboxes, quotes, paragraphs) is rendered by the view with
  `AttributedString(markdown:, options: .inlineOnlyPreservingWhitespace)` after `PageLinks.inlineMarkdown`.

### `PageLinks`
- `titles(in body:) -> [String]` — every `[[…]]` target (trimmed, non-empty), in order, no duplicates
  (normalized compare). `[[Title|label]]` → target "Title", shown as "label".
- `key(_ title:) -> String` — `PeopleDirectory.normalize` (case/diacritic-insensitive, trimmed).
- `resolve(_ title:, in pages:) -> NotePage?` — matching `key`; several → most recent `updatedAt`.
- `backlinks(to page:, in pages:) -> [NotePage]` — other pages whose `titles` contain the page's key,
  most recently updated first.
- `rename(from old:, to new:, in pages:, now:)` — rewrites `[[old]]` and `[[old|label]]` (key match) to the
  new title in every page body, bumping `updatedAt` only on pages that changed. No-op when keys are equal.
- `inlineMarkdown(_ text:) -> String` — turns `[[Title]]` into `[Title](dayfold-page:Title%20escaped)` and
  `[[Title|label]]` into `[label](dayfold-page:…)` for rendering.
- `completionToken(in text:) -> String?` — the partial after an unclosed `[[` at the end of `text`
  (for the title suggestion strip); nil otherwise.

### Search
`Search.pages(_ pages: [NotePage], query:) -> [NotePage]` — plain words only (any `#`, `@`, `is:` token →
`[]`), AND, normalized substring over title + body, title matches first, then most recently updated.

## Screens

### Notes tab (`NotesView`)
- **iPhone:** fifth tab "Notes", symbol `books.vertical` (Today · People · Search · Journal · Notes).
  **Mac:** sidebar item "Notes" after Journal. DEBUG `-notes` opens it; `-page <title prefix>` opens a page.
- `.searchable(prompt: "Search notes")` → results across all pages (with a breadcrumb caption) via
  `Search.pages`; otherwise sections **Pinned** and **Pages** (top-level pages A–Z, each row with a
  subpage count caption when > 0). Rows: `displayTitle` (serif), first body line preview (secondary,
  1 line), updated date (caption).
- Toolbar "+" "New Page" (Mac ⌥⌘P): creates a top-level page and opens it in edit mode, title focused.
- Swipe / context menu on rows: Pin/Unpin, Delete (confirmation).
- Empty: serif "No pages yet" + "Tap + to start your wiki."

### Page (`PageView`)
- Breadcrumb (ancestors, tappable) above a serif large title; rendered blocks: headings serif, bullets
  with indent, checkboxes as tappable ○/✓ rows (44pt) that call `toggleCheckbox` and save, quotes with a
  leading rule, code in a monospaced `Color.card` box, dividers. Links (`dayfold-page:`) open the target
  page; a missing target asks "Create page “X”?" and creates a top-level page titled X (Claude's call:
  top-level so it's easy to find; Move… can file it later), then opens it in edit mode. Other URLs open
  normally.
- Sections after the body: **Subpages** (rows + "New Subpage") and **Linked from** (backlinks).
- Toolbar: Edit/Done; Pin/Unpin; Share (`ShareLink` with "# Title\n\nbody"); menu: Move… (picker of all
  pages except itself and its descendants, plus "Top level"), Delete Page (confirmation "Delete “Title”?"
  message "Its subpages move up a level.").
- **Edit mode** (inline, same screen): title `TextField` (serif, "Title"); body `TextEditor` (placeholder
  "Write in Markdown…"); an insert row above the editor with buttons Heading (`# `), Bullet (`- `),
  Checkbox (`- [ ] `), Link (`[[`, left open so the suggestion strip shows) that insert at the end of the body (cursor placement isn't available
  for `TextEditor` on iOS 17 — append on a new line); a suggestion strip of matching page titles while
  `completionToken` is non-nil (tap completes `[[Title]]`). Edits write straight to the model (autosave,
  `updatedAt = now` on change). On leaving edit mode (Done, back, tab switch): if the title changed,
  `PageLinks.rename` from the title at edit start; if the page `isBlank`, delete it.
- Empty body in view mode: secondary "Tap to write." — tapping it starts editing (as Edit).

### Search tab
A "Notes" section (after Journal, before tasks) when `Search.pages` matches; rows = title + breadcrumb
caption; tap → the page.

## Testing (Swift Testing)
- `NotePage` helpers; `Pages.delete` reparents children (to grandparent / top level); `move` refuses
  cycles; `breadcrumb` order and cycle guard; `descendants`.
- `PageMarkup.blocks`: each block kind incl. nested bullets, `[X]`, unclosed fence, paragraphs joining,
  blank lines, divider vs bullet `- `; `toggleCheckbox` flips only its line, leaves others.
- `PageLinks`: titles incl. `|label` and duplicates; resolve case/diacritics + most recent; backlinks;
  rename incl. label form and untouched pages keep `updatedAt`; inlineMarkdown escaping (spaces, `&`,
  `#`); completionToken (open `[[`, closed `[[x]]`, nested).
- `Search.pages`: AND, title-first ordering, token exclusion.
UI: DemoData pages ("Release process" with headings/steps/code, "Team — Platform" linking
[[Release process]] and [[Onboarding]], "Onboarding" with checkboxes and a subpage "Laptop setup", one
pinned); screenshot pass iPhone 16 Pro light/dark + SE.

## Left to the builder
Exact spacing and block styling, row layout, breadcrumb overflow (truncate middle), Mac sheet/sidebar
details, insert-row styling.
