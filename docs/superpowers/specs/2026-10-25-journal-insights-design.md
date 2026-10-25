# Journal & insights — design

Date: 2026-10-25 · Status: owner asked for a proposal ("help me"), then said "Proceed" to it. The proposal's
shape (Week page with Done / Stuck / Waiting on / one-line notes / Copy as update; month view later; no
gamification) is theirs by approval; every detail below is Claude's call and open to override.
Roadmap: (1) icon ✅ → (2) People ✅ → (3) Find & organise ✅ → (4) Capture everywhere ✅ → **(5) Journal & insights**.

## Why

Dayfold is good at today and tomorrow, but nothing helps you look back. On a Friday you want to know
what you actually delivered and to whom, what keeps rolling forward without moving, and who still owes
you — and you often have to say that out loud in a status update. A one-line note per day turns the log
into a light diary without becoming a journaling app.

## Goals

1. **Week page**: one calm screen per week — Done (grouped by person), Stuck, Waiting on, daily notes.
2. **Daily note**: an optional "How did today go?" line at the end of the evening Review, editable later.
3. **Copy as update**: the week as plain text, ready to paste into Slack or email.

## Non-goals (this round)

Month view and calendar heat map (next round), charts, AI summaries, PDF/file export, notes for days
other than through Review or the Week page, editing tasks in bulk.

## Anti-goals

- Gamification: no streaks, scores, badges, percentages, or "productivity" language.
- Guilt: Stuck is an invitation to decide (done / push / drop), in neutral colours, never red.
- Daily notes leaving the owner's iCloud: they are never part of the shared update text.
- Breaking CloudKit sync rules or losing data on upgrade.

## Constraints

As the app: iOS 17 / macOS 14 one codebase; SwiftData + CloudKit (defaults or optionals, no unique,
raw-string enums, optional relationships); logic in `DayfoldCore` with Swift Testing tests; views thin;
calm journal style (ink, paper, serif titles and empty states, 44pt targets, Dynamic Type, Reduce Motion).

## Data model — one additive model

`DayNote` (@Model, DayfoldCore): `id: UUID = UUID()`, `day: Date = startOfDay(now)`, `text: String = ""`,
`updatedAt: Date = Date()`. Add to the app schema. **Before TestFlight: deploy `DayNote` to the CloudKit
production schema.**

`DayNotes` (DayfoldCore):
- `note(for day:, in context) -> DayNote?` — the note whose `day` is that calendar day.
- `set(_ text:, for day:, now:, calendar:, in context)` — trims; empty deletes the note; otherwise
  updates or inserts and sets `updatedAt = now`.
- `dedupe(in context)` — two devices can each create a note for the same day offline. Merge same-day
  notes into the oldest (`updatedAt`, ties → `id.uuidString`): distinct non-empty texts joined with
  `"\n"` in `updatedAt` order, `updatedAt` = newest; delete the rest. Called from `Maintenance.tidy`.

## Week rules — `WeekReview` (DayfoldCore, tested)

`WeekReview(entries: [Entry], notes: [DayNote], containing date: Date, today: Date, calendar:)`
- `interval`: `calendar.dateInterval(of: .weekOfYear, for: date)` (respects the locale's first weekday).
- `isCurrent`: `interval` contains `today`.
- `done: [PersonGroup]`: tasks with status `.done` and `closedAt` in `interval`. Grouped by
  `entry.person` (delegated `to` tasks done count under that person too); entries with no person go in a
  group with `person == nil`, shown as "Everything else", always last. Other groups by entry count desc,
  then name. Within a group, by `closedAt`.
- `droppedCount`: tasks `.dropped` with `closedAt` in `interval`.
- `stuck: [Entry]` (current week only, else empty): active own tasks (`!isWaiting`) with
  `showOn <= today` and `DayPage.age(of:on: today) >= 3` (the amber threshold), oldest `createdAt` first.
- `waiting: [PersonGroup]` (current week only, else empty): `isWaiting` entries grouped by person,
  oldest `delegatedAt` first within a group; groups by their oldest item.
- `notes: [DayNote]`: notes whose `day` is in `interval`, by day.
- `summaryText(title:) -> String`: plain text, no notes:

```
Week of 19 Oct
Done (3)
• Send deck — Meera
• Budget numbers — Ravi
• Weekly report
Still open (1)
• Fix login bug (6d)
Waiting on (1)
• Ravi: contract draft (4d)
```
  Sections with nothing are omitted. "— Name" only when a person is linked. "Still open" lists `stuck`;
  "Waiting on" lists waiting entries as "Name: text (Nd)" with `Review.waitingDays`. Past weeks have only
  Done. `title` is formatted by the view (e.g. "Week of 19 Oct").

`PersonGroup`: `id` (person id or a fixed id for nil), `person: Person?`, `entries: [Entry]`.

## Screens

### Week page (`WeekView`)
- **iPhone:** fourth tab "Week", symbol `book.closed` (Today · People · Search · Week).
  **Mac:** sidebar item "This week" under Today, same symbol.
- Header: serif "Week of 19 Oct" (first day of `interval`), previous/next week chevrons (next disabled on
  the current week), a "This week" button when not current; one quiet line "12 done · 2 dropped" (omit zero
  parts; nothing when both zero).
- Sections (each only when non-empty), `EntryRow` rows, tap → `EntryEditor`, person name tap → person page:
  - **Done** — per-person sub-headers (name, or "Everything else").
  - **Stuck** (current week) — caption "Open 3+ days. Finish, push or let go." Swipe/context actions:
    Done, Push to tomorrow, Drop, via `Review.apply(_:to:now:calendar:context:)`.
  - **Waiting on** (current week) — per-person sub-headers.
  - **Notes** — one row per day that has a note ("Mon 19 · text", serif text); for the current week,
    today's row shows "Add a note for today" when empty. Tap → small sheet with a multi-line field, Save /
    Cancel, empty = delete (via `DayNotes.set`).
- Empty week (nothing in any section): serif "A quiet week" + secondary "Nothing was closed this week."
- Toolbar: **Share update** (`ShareLink` with `summaryText`) and **Copy** (pasteboard, brief "Copied"
  confirmation). Both hidden when the week has nothing to share.

### Evening Review
- The summary step ("All folded") gains an optional field: placeholder "How did today go?", one to three
  lines, prefilled with today's note. Saved with `DayNotes.set` on Close, on submit, and on disappear.
  Not shown when the review is for a day other than today.

## Error handling & sync
- `DayNote` is additive; automatic migration. Duplicate same-day notes from offline devices merged by
  `Maintenance.tidy`. Notes are never in `summaryText`.

## Testing (Swift Testing, `ist` calendar; also a Monday-first calendar for the interval test)
- Interval follows `firstWeekday` (Sunday-first vs Monday-first give different weeks for the same date).
- Done: closed in week counted, closed outside not; delegated done grouped under person; nil group last;
  group order count desc then name; notes excluded from done.
- Dropped count. Stuck: age ≥ 3 only, waiting excluded, future `showOn` excluded, oldest first; empty for a
  past week. Waiting grouping and order; empty for a past week.
- `summaryText` exact output for the example above; omitted sections; past week only Done.
- `DayNotes.set` insert / update / empty deletes; `note(for:)` matches by calendar day; `dedupe` merges
  texts in order and keeps one; `Maintenance.tidy` runs it.
UI: extend `DemoData` (several done this week across two people + one with no person, one dropped, one
stuck task ≥ 3 days, notes on two days) and a DEBUG `-week` flag opening the Week tab/sidebar.

## Left to the builder
Exact spacing, chip vs. header styling for person groups, sheet sizing, copy-confirmation style.
