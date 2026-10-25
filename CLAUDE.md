# Dayfold — notes for Claude Code

Open-source Mac + iPhone daily log / bullet journal with automatic carry-forward.
Owner drives Xcode; Claude writes code and reviews. Read `docs/spec.md` first.

## Layout
- `dayfold/` — SwiftUI app target (iOS 17 / macOS 14). Synchronized folder: new files are picked up automatically.
- `dayfold/Views/` — screens. `DayPageView.swift` is the root screen.
- `dayfold/Views/SearchView.swift`, `SearchRouter.swift` — Search tab/sidebar; `EntryEditor.swift` — edit sheet (priority, repeat, tags, checklist).
- `dayfold/Views/People/` — people list, person page, person editor, all-waiting.
- `dayfold/Views/Journal/` — Journal tab (iPhone tab / Mac sidebar "Journal"): `JournalView` (Insights card, filters, entry cards, +), `JournalEditor` (draft-only sheet, photos, suggestions), `JournalLock` (Face ID / Touch ID / passcode lock + cover), rows/cards/thumbnails.
- `dayfold/Views/Notes/` — Notes tab (iPhone tab / Mac sidebar "Notes"; on Mac the sidebar also has a "Pages" section: pinned then the top-level page tree, "+" New Page, selecting opens the page in the detail — `RootView`): `NotesView` (Pinned/Pages list, search, +), `PageView` (`PageRoute`, rendered page, breadcrumb, Subpages, Linked from, Pin/Share/More/Edit; on compact width Pin and Share sit in More), `PageBlocksView` (Markdown blocks), `PageEditor` (inline title/body editor + Notes-style format bar acting on the selection, iOS 18 / macOS 15; earlier OSes apply at the end).
- `dayfold/Views/WeekView.swift` — Week page (pushed from Journal ▸ "This week"): Done by person, Stuck, Waiting on, journal entries (Notes), Share update / Copy.
- `DayfoldCore/` — local Swift package, **no UI**: `Entry` model, `DayPage` rule, `Review` actions, `CaptureParser`, `Recurrence`, `Maintenance`, `Search`, `Tags`, `ChecklistItem`, `Capture` (the one capture path), `JournalEntry` / `JournalPhoto` + `Journal` (reflection, DayNote migration, dedupe), `JournalInsights` (month calendar, counts), `JournalSuggestions`, `PhotoImport` (downscale to 2048 px JPEG), `DayNote` (legacy, migrated into `JournalEntry` by `Maintenance.tidy`; stays in the schema), `WeekReview` (week rules + update text), `NotePage` + `Pages` (wiki page model, tree rules: breadcrumb, move, delete reparents), `PageMarkup` (Markdown blocks incl. numbered lists, checkbox toggle), `PageFormat` (format-bar edits on text + selection: line styles, `**`/`_`/`++`/`~~` wraps, indent, link, divider, code block), `PageLinks` (`[[wiki links]]`, resolve, backlinks, rename rewrite), Swift Testing tests. Language mode 5.
- `dayfold/Views/CaptureRouter.swift` — ⌘N "New Entry", `EntryScope.lastUsed`; `dayfold/AppStore.swift` — shared `ModelContainer` for intents/Services.
- `dayfold/Intents/` — Siri/Shortcuts "Add to Dayfold". `dayfold/Mac/` — global hotkey (`HotKey`), `QuickCapturePanel`, `MacAppDelegate` (hotkey + Services provider).
- `docs/spec.md` — v0.1 spec + decisions log. Append decisions there.

## Rules
- SwiftData + CloudKit automatic sync: every `Entry` property has a default or is optional; no `@Attribute(.unique)`; enums stored as raw strings. Don't break this.
- Carry-forward is a query (`DayPage.contains`), never a copy. Put logic in `DayfoldCore` with tests; views stay thin.
- Both platforms from one codebase; prefer APIs available on iOS 17 and macOS 14.
- Container `iCloud.com.rockykusuma.dayfold`, bundle id `com.rockykusuma.dayfold.app`. Push Notifications capability is on (CloudKit silent pushes drive live sync); no APNs certificates needed.
- Don't commit `xcuserdata`. Don't run `swift test` outside Xcode for the package (SwiftData is Apple-only); use ⌘U on the `DayfoldCore` scheme.

## Design
- Calm journal look, all native: ink accent (`AccentColor`), `Paper` background, `Card` surfaces — asset-catalog colors with dark variants (`Color.paper`, `Color.card`). Serif (`design: .serif`) for dates, Review card text, empty states; system font elsewhere.
- Bullet marks: ○ task (44pt tap target), – note. Age pill turns amber at 3+ days. Haptics via `.sensoryFeedback`; animations `.snappy`, respect Reduce Motion.
- Debug only: launch with `-demo` for an in-memory sample day (no iCloud, no permission prompt); add `-review` to open Review (`-waiting` starts on the first waiting card), `-settings` for Settings, `-people` (iOS) for the People tab, `-person <Name>` (iOS) for that person's page, `-search [query]` for the Search tab/sidebar with an optional query, `-journal` for the Journal tab / sidebar (`-week` also pushes the Week page), `-edit <text prefix>` to open the editor for the first matching entry (with `-journal`: the first journal entry whose title or text starts with it), `-notes` for the Notes tab / sidebar (`-page <title prefix>` also opens the first matching page; add `-editing` to open it in edit mode), `-locked` to force the journal lock on (locked state screenshots; with no device passcode, Unlock opens it without a prompt). `DemoData.swift`.

## State as of 2026-10-25
- v0.1 screens done: `DayPageView`, `ReviewView`, `SettingsView`, `ReviewReminder` (see Layout). Mac menu-bar capture: `Views/MenuBarCapture.swift`.
- People & delegation done: `Person.swift`, `PeopleDirectory.swift`, `PersonPage.swift` (DayfoldCore), `Views/People/*`, `RootView.swift` (iPhone tabs, Mac sidebar). Debug flags: `-demo`, `-review`, `-settings`, `-people`.
- Find & organise done: search, tags, checklists, repeating tasks, priority (see spec decisions log).
- Journal & insights done: Week page, Share update / Copy (see spec decisions log). The Review "How did today go?" line is now a journal entry (the day's reflection), no longer a separate daily note.
- Journal done: Journal tab (Insights calendar, filters, entry cards, editor with photos + suggestions), entries in Search / Week page (not on the Day page — the owner keeps the journal in its own tab), Review reflection as a journal entry, optional Face ID lock. DayNotes migrate into entries on tidy. Spec: docs/superpowers/specs/2026-10-25-journal-design.md
- Owner checks pending (journal): with the lock on, nothing from the journal shows on the Journal tab, Search, Week page or Review field until unlocked; it is covered in the app switcher, relocks after backgrounding (Mac: on switching to another app) and an open editor keeps its draft under the cover; turning the lock off while locked asks for Face ID / Touch ID first; the photo picker on a real device; Return in the Review "How did today go?" field.
- Notes (wiki) done: Notes tab (pinned + top-level pages, search with breadcrumbs), pages in light Markdown with view/edit in place, `[[wiki links]]` with backlinks and rename rewriting, subpages + Move…, pages in Search. Spec: docs/superpowers/specs/2026-10-25-notes-wiki-design.md
- Owner checks pending (notes): editing a page on a real device (keyboard, format bar on a selection and at the caret, saved as you type); tapping a link to a missing page → "Create page" opens it in edit mode; Move… to another parent and to Top level; renaming a page rewrites `[[links]]` in other pages; kill the app mid-rename, relaunch, links still resolve; checkbox rows at the largest accessibility text size. Mac: the sidebar Pages tree (expand subpages, select opens, "+" opens a new page in edit mode, deleting the open page returns to Notes, collapse the section).
- Before the first TestFlight build: deploy the CloudKit schema (Person, ChecklistItem, DayNote, JournalEntry, JournalPhoto, NotePage + new Entry fields) to production in the CloudKit Console.
- Builds Debug + Release on macOS + iOS. DayfoldCore tests: run from `DayfoldCore/` with `xcodebuild test -scheme DayfoldCore -destination platform=macOS`.
- Capture everywhere done: one Core path (`Capture.add` / `addLines`), ⌘N, list paste/drop, Siri/Shortcuts, Mac hotkey panel, Services "Add to Dayfold". Spec: docs/superpowers/specs/2026-10-25-capture-everywhere-design.md
- Owner checks pending: hotkey panel focus (toggle twice, click-away), Siri/Shortcuts run, Services menu appears (run `/System/Library/CoreServices/pbs -update` if not), ⌘N from Search/People and with the window minimized, pasting a Windows (CRLF) list; hotkey default is ⌃⌥D.
- Not yet: month view / calendar heat map, share extension and widgets (need targets + App Group); notification permission is requested at first launch (consider asking contextually).
- Owner checks pending: set First Day of Week to Monday on iPhone and Mac (Language & Region) so the Week page and update title start on Monday.
