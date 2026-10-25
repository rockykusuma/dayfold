# Journal & Insights Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Week page (Done by person, Stuck, Waiting on, daily notes, Copy as update) and an optional daily note at the end of the evening Review.

**Architecture:** One additive SwiftData model (`DayNote`) with `DayNotes` helpers and same-day dedupe in `Maintenance.tidy`. All week rules and the update text live in a pure `WeekReview` value in `DayfoldCore`, tested. The app adds `WeekView` (fourth iPhone tab, Mac sidebar item) and a note field on Review's summary step.

**Tech Stack:** Swift 5 language mode, SwiftUI (iOS 17 / macOS 14), SwiftData + CloudKit, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-10-25-journal-insights-design.md`

## Global Constraints

- iOS 17 / macOS 14, one codebase; no packages, targets or entitlement changes.
- CloudKit: every stored property defaulted or optional; no `@Attribute(.unique)`; enums as raw strings; relationships optional with inverses. `DayNote` is the only new model; nothing else in the schema changes.
- Logic in `DayfoldCore` with Swift Testing tests; views thin.
- Anti-goals: no streaks, scores, badges, percentages or productivity language; Stuck uses neutral colours (never red); daily notes are never in the update text.
- Copy (verbatim): tab "Week" / sidebar "This week", symbol `book.closed`; header "Week of <d MMM>" (e.g. "Week of 19 Oct"); button "This week"; counts line "<n> done · <n> dropped" (omit zero parts); sections "Done", "Stuck", "Waiting on", "Notes"; nil-person group "Everything else"; Stuck caption "Open 3+ days. Finish, push or let go."; actions "Done", "Push to tomorrow", "Drop"; "Add a note for today"; empty state "A quiet week" / "Nothing was closed this week."; toolbar "Share update", "Copy", confirmation "Copied"; Review placeholder "How did today go?"; update text headings "Done (n)", "Still open (n)", "Waiting on (n)".
- Style: ink accent (`.tint`), `Color.paper` backgrounds, `Color.card` surfaces, serif for the week header, note text and empty state; 44pt targets; `.snappy`; Reduce Motion; Dynamic Type through accessibility sizes.
- Tests: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS` (focus `-only-testing:DayfoldCoreTests/<Suite>`). Never `swift test`.
- After every task that touches `dayfold/`, both builds pass:
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO`
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
- Commit trailers (every commit, exactly):
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_016KuWvS3f2pThajg7yChjq9`
- Core tests: `import Foundation`, `import SwiftData`, `import Testing`, `@testable import DayfoldCore`; `@MainActor` suites with `makeContainer()` (PeopleModelTests.swift — add `DayNote.self` to it) and `ist` / `at(y,m,d,h)` (TestSupport.swift; `ist` is Gregorian, firstWeekday 1 = Sunday). 2026-10-19 is a Monday.

## Review Focus

1. **A week across a month or year boundary** (Sun 27 Dec 2026 – Sat 2 Jan 2027 in `ist`): interval and grouping correct. Test `yearBoundary` in Task 2.
2. **A task closed at the very edge of a week** (23:30 on the last day vs 00:10 on the next week's first day): counted in exactly one week; the interval end is exclusive. Test `edgeOfWeek` in Task 2.
3. **A task done then reopened** (`Review.reopen` clears `closedAt`): not in Done any more. Test `reopenedNotDone` in Task 2.
4. **A note set at 00:05 and read at 23:50 the same day** (and vice versa): one note, matched by calendar day. Test `noteAnyTime` in Task 1.
5. **Closing Review without typing**: no empty `DayNote` is created, and an existing note is left untouched when the field is unchanged. Test `emptyNoOp` in Task 1 (Core half); Task 3 saves only when the text changed.

---

### Task 1: `DayNote` model and `DayNotes`

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/DayNote.swift`
- Modify: `DayfoldCore/Sources/DayfoldCore/Maintenance.swift`, `DayfoldCore/Tests/DayfoldCoreTests/PeopleModelTests.swift` (`makeContainer` schema), `dayfold/AppStore.swift` and `dayfold/DemoData.swift` (schemas gain `DayNote.self`)
- Test: `DayfoldCore/Tests/DayfoldCoreTests/DayNoteTests.swift`

**Interfaces:**
- Produces:
  ```swift
  @Model public final class DayNote { public var id: UUID = UUID(); public var day: Date; public var text: String = ""
      public var updatedAt: Date = Date()
      public init(day: Date, text: String, updatedAt: Date = Date(), calendar: Calendar = .current) } // day = startOfDay
  public enum DayNotes {
      public static func note(for day: Date, calendar: Calendar = .current, in context: ModelContext) throws -> DayNote?
      public static func set(_ text: String, for day: Date, now: Date = Date(), calendar: Calendar = .current,
                             in context: ModelContext) throws
      public static func dedupe(in context: ModelContext) throws
  }
  ```
  (`day` needs a default for CloudKit: `= Calendar.current.startOfDay(for: Date())`, like `Entry.showOn`.)

Rules: `set` trims whitespace/newlines; empty → delete the day's note(s) if any, insert nothing; else update the existing note (text, `updatedAt = now`) or insert one. Does not save. `note(for:)` matches `calendar.isDate(note.day, inSameDayAs: day)`. `dedupe`: for each calendar day with 2+ notes keep the oldest by (`updatedAt`, then `id.uuidString`); its text = distinct non-empty texts of all of them in `updatedAt` order joined by `"\n"`; its `updatedAt` = the newest; delete the others. `Maintenance.tidy` calls `DayNotes.dedupe` before its save.

- [ ] **Step 1: Write the failing tests** (`@Suite("Day notes") @MainActor struct DayNoteTests`, `ist`):
  - `insertAndUpdate`: `set("Good day", for: at(2026,10,19,21), now: at(2026,10,19,21))` → one note, `day == at(2026,10,19)`, text "Good day"; `set("Better", …)` same day → still one note, text "Better", `updatedAt` = the second `now`.
  - `trims`: `set("  hi \n", …)` → text "hi".
  - `emptyDeletes`: after a note exists, `set("   ", …)` → zero notes.
  - `emptyNoOp`: `set("", for: at(2026,10,20,9), …)` with no note → zero notes inserted.
  - `noteAnyTime`: `set("x", for: at(2026,10,19,0)…)` (00:05 via `addingTimeInterval(300)`), `note(for: at(2026,10,19,23)…)` returns it; `note(for: at(2026,10,20,0)…)` is nil.
  - `dedupeMerges`: insert three notes for 19 Oct with texts "A" (updatedAt 20:00), "B" (21:00), "A" (22:00), plus one for 20 Oct → after `dedupe`: two notes total; the 19 Oct note text `"A\nB"`, `updatedAt == at(2026,10,19,22)`.
  - `tidyDedupes`: two same-day notes → `Maintenance.tidy(in:)` → one note.
- [ ] **Step 2: Run** `… -only-testing:DayfoldCoreTests/DayNoteTests` — expect compile failure.
- [ ] **Step 3: Implement** `DayNote.swift`, update `Maintenance.tidy`, add `DayNote.self` to `makeContainer`, `AppStore` schema and `DemoData.container`.
- [ ] **Step 4: Run the suite, the full core suite, and both app builds** — `** TEST SUCCEEDED **`, `** BUILD SUCCEEDED **` ×2.
- [ ] **Step 5: Commit** `Day notes: model, set/dedupe, tidy`.

---

### Task 2: `WeekReview`

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/WeekReview.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/WeekReviewTests.swift`

**Interfaces:**
- Consumes: `DayNote` (Task 1); `DayPage.age(of:on:calendar:)`, `Review.waitingDays(_:on:calendar:)`, `Entry.isWaiting`.
- Produces:
  ```swift
  public struct PersonGroup: Identifiable { public let id: String; public let person: Person?; public let entries: [Entry] }
  public struct WeekReview {
      public let interval: DateInterval; public let isCurrent: Bool
      public let done: [PersonGroup]; public let droppedCount: Int
      public let stuck: [Entry]; public let waiting: [PersonGroup]; public let notes: [DayNote]
      public var isEmpty: Bool      // done, stuck, waiting, notes all empty and droppedCount == 0
      public init(entries: [Entry], notes: [DayNote], containing date: Date, today: Date, calendar: Calendar = .current)
      public func summaryText(title: String, calendar: Calendar = .current) -> String
  }
  ```
  `PersonGroup.id` = `person.id.uuidString`, or `"none"` for the nil group.

Rules: exactly the spec's "Week rules" section. Only `kind == .task` entries count anywhere. `interval` from `calendar.dateInterval(of: .weekOfYear, for: date)`; membership is `interval.start <= d && d < interval.end`. `today` for `stuck`/`waiting`/`isCurrent` is the passed `today`. `summaryText`: lines exactly as the spec example (bullet `•` U+2022, em dash `—` U+2014 with spaces, `(Nd)`), sections separated by nothing extra (one heading line then its bullets), empty sections omitted, `title` first line; Done bullets in group order (named groups then "Everything else"), each "• text — Name" or "• text"; "Still open" bullets "• text (Nd)" with `DayPage.age`; "Waiting on" bullets "• Name: text (Nd)" with `Review.waitingDays`. No trailing newline.

- [ ] **Step 1: Write the failing tests** (`@Suite("Week review") @MainActor struct WeekReviewTests`, `ist`, week of Sun 18 – Sat 24 Oct 2026, `today = at(2026,10,23,18)`; helper to make a done task with `closedAt`):
  - `intervalFollowsFirstWeekday`: for `at(2026,10,19,12)`, `ist` (Sunday-first) interval start `at(2026,10,18)`; a copy of `ist` with `firstWeekday = 2` → start `at(2026,10,19)`.
  - `doneGrouping`: done tasks — 2 linked to Meera (`.from`), 1 delegated to Ravi (`Review.delegate`, then `.done`), 1 with no person, 1 note (kind `.note`) → `done.map { $0.person?.name }` == `["Meera", "Ravi", nil]`; Meera's entries ordered by `closedAt`; the note absent.
  - `edgeOfWeek`: closed `at(2026,10,24,23)` + 30 min → in this week; closed `at(2026,10,25,0)` + 10 min → not in this week, and in the week containing 25 Oct.
  - `droppedCount`: two dropped in week, one outside → 2.
  - `reopenedNotDone`: done in week then `Review.reopen` → not in `done`.
  - `stuckRule`: own open task created `at(2026,10,19,9)` (age 4) → stuck; created `at(2026,10,22,9)` (age 1) → not; waiting task age 6 → not in stuck; open task with `showOn` 26 Oct → not; order oldest `createdAt` first.
  - `waitingGroups`: two waiting on Ravi (delegated 15 and 20 Oct), one on Meera (17 Oct) → groups `["Ravi", "Meera"]` (by oldest item), Ravi's entries oldest `delegatedAt` first.
  - `pastWeekHasNoStuckOrWaiting`: same data, `containing: at(2026,10,12,12)` → `isCurrent == false`, `stuck` and `waiting` empty.
  - `notesInWeek`: notes 19 and 21 Oct + 26 Oct → `notes.map(\.day)` == `[at(2026,10,19), at(2026,10,21)]`.
  - `summaryTextExample`: build the spec's example (Meera "Send deck" from, Ravi "Budget numbers" delegated-then-done, "Weekly report" no person; stuck "Fix login bug" created 6 days before `today`; waiting on Ravi "Contract draft" delegated 4 days before) with a note present → `summaryText(title: "Week of 19 Oct")` equals exactly:
    `"Week of 19 Oct\nDone (3)\n• Send deck — Meera\n• Budget numbers — Ravi\n• Weekly report\nStill open (1)\n• Fix login bug (6d)\nWaiting on (1)\n• Ravi: Contract draft (4d)"` and does not contain the note's text. (Use one done per person so group order is by name; Meera before Ravi.)
  - `summaryPastWeek`: a past week with one done → only title + "Done (1)" + its bullet.
  - `yearBoundary`: done `at(2026,12,31,10)` and `at(2027,1,2,10)`, `containing: at(2026,12,29,12)` → interval start `at(2026,12,27)`, both done counted.
- [ ] **Step 2: Run** `… -only-testing:DayfoldCoreTests/WeekReviewTests` — expect compile failure.
- [ ] **Step 3: Implement `WeekReview.swift`.**
- [ ] **Step 4: Run the suite and the full core suite** — `** TEST SUCCEEDED **`.
- [ ] **Step 5: Commit** `Week review: done by person, stuck, waiting, update text`.

---

### Task 3: Daily note in the evening Review

**Files:**
- Modify: `dayfold/Views/ReviewView.swift` (summary step)

**Interfaces:**
- Consumes: `DayNotes.note(for:in:)`, `DayNotes.set(_:for:in:)` (Task 1).

- [ ] **Step 1:** On the summary step (below the tally, above Close), when the review's day is today: a `TextField("How did today go?", text:, axis: .vertical)` with `.lineLimit(1...3)`, serif body font, `Color.card` rounded background, 44pt min height. Prefill from `DayNotes.note(for: today, in: context)?.text` when the summary appears. Save via `DayNotes.set` on Close, on submit, and on disappear — **only when the text differs from the prefilled value** (Review Focus 5). Close keeps `.keyboardShortcut(.defaultAction)`; Return in the field submits (saves) without closing on iOS. Don't show the field when Review's day isn't today (read how ReviewView determines its day; if it is always today, say so in the report and show it always).
- [ ] **Step 2: Build both platforms + full core suite.**
- [ ] **Step 3: Commit** `Review: a one-line note for today`.

---

### Task 4: Week page, navigation, demo data, docs

**Files:**
- Create: `dayfold/Views/WeekView.swift`
- Modify: `dayfold/Views/RootView.swift` (iPhone tab 3 "Week"; Mac sidebar "This week" under Today; DEBUG `-week`), `dayfold/DemoData.swift`, `CLAUDE.md`, `docs/spec.md`

**Interfaces:**
- Consumes: `WeekReview`, `PersonGroup` (Task 2); `DayNotes` (Task 1); existing `EntryRow`, `EntryEditor`, `PersonView` navigation pattern used by `SearchView` (row tap → editor sheet, person tap → person page), `Review.apply(_:to:now:calendar:context:)`.

- [ ] **Step 1: `WeekView`** per the spec's "Week page" section and the copy in Global Constraints. `@Query` entries and notes; `@State var anchor: Date` (any date in the shown week); build `WeekReview(entries:notes:containing: anchor, today: Date())`. Header title from `review.interval.start` formatted `.dateTime.day().month(.abbreviated)` → "Week of 19 Oct". Chevrons move `anchor` by ±7 days (next disabled when `isCurrent`); "This week" resets. Stuck rows: leading swipe Done; trailing swipe Push to tomorrow and Drop; same three in the context menu (Mac). Notes: rows "Mon 19 · text" (`.dateTime.weekday(.abbreviated).day()`), tap → sheet with `TextField(axis: .vertical)` 3–8 lines, Cancel / Save (Save calls `DayNotes.set`, empty deletes); current week shows "Add a note for today" when today has none. Toolbar: `ShareLink(item: review.summaryText(title:), subject: Text(title))` labelled "Share update", and "Copy" (`UIPasteboard`/`NSPasteboard`, then a transient "Copied" label for ~1.5 s, Reduce-Motion-safe). Both hidden when `done`, `stuck` and `waiting` are all empty. Empty state when `review.isEmpty`.
- [ ] **Step 2: Navigation.** iPhone: fourth tab `NavigationStack { WeekView() }`, label "Week", `book.closed`, tag 3. Mac: `SidebarItem.week`, `Label("This week", systemImage: "book.closed")` directly under Today; detail `NavigationStack { WeekView() }`. DEBUG `-week` selects it (same pattern as `-search`).
- [ ] **Step 3: Demo data.** This week: done tasks closed on different days — two from Meera, one delegated to Arjun then done, one with no person; one dropped; one own open task created 4 days ago (stuck); notes for yesterday and two days ago. Keep existing demo content.
- [ ] **Step 4: Docs.** `CLAUDE.md`: Layout gains `WeekView.swift`, `DayNote`, `WeekReview` (Core); debug flags gain `-week`; State gains "Journal & insights done" and the CloudKit reminder now lists `DayNote`; "Not yet" gains month view / heat map. `docs/spec.md` decisions log: week follows locale first weekday; Stuck = open own tasks age ≥ 3; Stuck and Waiting only on the current week; notes never in the update text; same-day notes merged by tidy.
- [ ] **Step 5: Build both platforms + full core suite.** Then an iOS screenshot pass with `-demo -week` on the iPhone 16 Pro simulator (`6EA53D1E-31C4-49B6-A404-84BE3F1D1104`) and SE (`F837D4E4-ADD4-4F3D-BB1A-544FB655C320`), light and dark, via `xcrun simctl io <id> screenshot` (simulator only — never capture the desktop); fix layout problems you see.
- [ ] **Step 6: Commit** `Week page: done by person, stuck, waiting, notes, share update`.
