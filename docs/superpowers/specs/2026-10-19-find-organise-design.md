# Find & organise — design

Date: 2026-10-19 · Status: owner skipped questions ("just start"); every decision below is Claude's call and open to override.
Roadmap: (1) app icon ✅ → (2) People & delegation ✅ → **(3) Find & organise** → (4) Capture everywhere → (5) Journal & insights.

## Why

Dayfold now holds weeks of entries across people and teams, but the only way back to an old item is
paging day by day. Tags are captured (`#hiring`) and never shown. Every task is the same weight, and
repeating chores (weekly reports, 1:1 prep) have to be re-typed. This project makes the log findable
and lets a task carry a little structure without turning Dayfold into a project manager.

## Goals

1. **Search** everything ever captured — text, tags, people — in one place.
2. **Tags** become visible and browsable.
3. **Checklists** inside a task (subtasks).
4. **Repeating tasks** that come back on their own.
5. **Priority**: mark the few things that matter today.

## Non-goals

Saved searches, smart lists, nested projects/areas, subtask due dates or assignees, custom recurrence
(every 2nd Tuesday), multiple priority levels, natural-language dates beyond today's parser, full-text
index outside SwiftData.

## Anti-goals

- Any change that turns the day page into a project board, or hides the timeline order of the log.
- Recurrence that piles up a backlog of missed copies.
- Anything that breaks CloudKit sync rules or loses data on upgrade.

## Constraints

Same as the app: iOS 17 / macOS 14 from one codebase; SwiftData + CloudKit (every stored property
defaulted or optional, no unique attributes, enums as raw strings, relationships optional with
inverses); logic in `DayfoldCore` with Swift Testing tests; views thin; calm journal style (ink,
paper, serif titles, 44pt targets, Dynamic Type, Reduce Motion).

## Data model (DayfoldCore) — additive only

### `Entry` additions

| Field | Type | Default | Meaning |
|---|---|---|---|
| `isPriority` | `Bool` | `false` | Starred. |
| `repeatRaw` | `String?` | `nil` | `RepeatRule` raw: `daily`, `weekdays`, `weekly:<weekday>`, `monthly:<day>`. Nil = one-off. |
| `seriesID` | `UUID?` | `nil` | Shared by every occurrence of one repeating task. |
| `checklist` | `[ChecklistItem]?` | `nil` | Subtasks; inverse of `ChecklistItem.entry`, delete rule `.cascade`. |

Existing `tags: [String]` stays as is (already synced).

### `ChecklistItem` (new @Model)

| Field | Type | Default |
|---|---|---|
| `id` | `UUID` | `UUID()` |
| `text` | `String` | `""` |
| `isDone` | `Bool` | `false` |
| `order` | `Double` | `0` (sort key; insert between = midpoint) |
| `createdAt` | `Date` | `Date()` |
| `entry` | `Entry?` | `nil` |

A separate model (not an embedded array) so two devices ticking different items merge cleanly.

## Rules (DayfoldCore, pure where possible, tested)

### Search — `Search`
- `Search.matches(_ entry, query:) -> Bool`. Query is split on whitespace into tokens; **every** token
  must match (AND). Matching is case- and diacritic-insensitive (reuse `PeopleDirectory.normalize`).
- Token kinds: `#tag` matches an entry tag exactly (normalized); `@name` matches the linked person's
  name or `from` text by prefix; `is:open`, `is:done`, `is:waiting`, `is:priority`, `is:repeating`,
  `is:note` filter state; anything else is a substring of text, tags, person name, from text, or any
  checklist item text.
- `Search.results(_ entries, query:) -> [Entry]`: matches, open tasks first, then newest `createdAt`
  first. Empty query → empty results (the screen shows browse content instead).
- `Search.dayGroups(_ results) -> [(day: Date, entries: [Entry])]` for display, newest day first.

### Tags — `Tags`
- Tags are stored as typed; compared normalized (`#Hiring` == `#hiring`).
- `Tags.all(_ entries) -> [(tag: String, count: Int)]`: distinct tags (display form = most recent
  spelling), count of entries, sorted by count desc then name.
- `Tags.parse(_ text) -> [String]` for the editor field: split on spaces/commas, strip leading `#`,
  drop empties and duplicates (normalized).

### Checklist — on `Entry`
- `Entry.sortedChecklist` (by `order`), `Entry.checklistProgress -> (done: Int, total: Int)?`
  (nil when empty).
- `Checklist.add(_ text, to entry, in context)` appends with `order = last + 1`; blank text ignored.
- Completing every item does **not** close the task (R decides); the row shows `5/5`.

### Recurrence — `Recurrence`
- `RepeatRule`: `daily` (every day), `weekdays` (Mon–Fri), `weekly(weekday:)` (same weekday, 1 = Sunday),
  `monthly(day:)` (same day-of-month, clamped to the month's last day).
- Raw values: `daily`, `weekdays`, `weekly:<weekday>` (e.g. `weekly:2` = Monday), `monthly:<day>`
  (e.g. `monthly:31`). When weekly is chosen (parser or editor) the anchor is the entry's `showOn`
  weekday and is copied to every later occurrence, so pushing one occurrence never moves the series;
  a bare `weekly` raw value (defensive) repeats on the occurrence's `showOn` weekday. When monthly is
  chosen (parser or editor) the anchor day is the entry's `showOn` day-of-month and is copied to every
  later occurrence, so Jan 31 → Feb 28 → Mar 31 (no drift to the 28th). A bare `monthly` raw value
  (defensive) anchors on the occurrence's `showOn` day.
- `Recurrence.nextShowOn(rule:, after showOn: Date, closedOn: Date, calendar:) -> Date`: the first rule
  date strictly after `max(startOfDay(showOn), startOfDay(closedOn))`. Closing a daily task three days
  late gives tomorrow, not three catch-up copies (anti-goal).
- `Recurrence.spawnNext(from entry, closedOn:, in context) -> Entry?`: when a repeating task is closed
  (done **or** dropped), insert the next occurrence: same `text`, `kind`, `scope`, `tags`, `isPriority`,
  `repeatRaw`, `seriesID` (assign one to the first occurrence if nil), `person` + `link`
  (a `to` link → next one is delegated again with `delegatedAt = createdAt`), `from`; `dueOn` shifted by
  the same offset from `showOn`; checklist copied **unchecked**; `showOn = nextShowOn`; `createdAt` =
  the new `showOn` day at the original occurrence's time of day (so it never looks old or stale).
  Returns nil for non-repeating entries or notes.
- Hook: `Review.apply(.done / .drop)` calls `spawnNext` (needs a context → new overload
  `Review.apply(_:to:now:calendar:context:)`; the context-free overload stays for tests/back-compat
  and never spawns). Reopening a closed occurrence does **not** delete the spawned next one.
- `Recurrence.dedupe(in context)`: delete duplicate **open** occurrences with the same `seriesID` and
  `showOn` (two devices closed the same occurrence offline), keeping the oldest `createdAt` (ties → lowest id, so every device keeps the same one). Runs in
  `PeopleDirectory.tidy` → rename to `Maintenance.tidy(in:)` that calls people backfill + merge +
  recurrence dedupe + save. Keep `PeopleDirectory.tidy` as a thin call to it.
- Stop: setting Repeat to Never clears `repeatRaw` on that occurrence only; already-spawned future
  occurrences are left (there is at most one, the next).

### Priority
- `isPriority` toggled from the row (context menu / swipe) and editor.
- Day page: starred open tasks are pinned in a **Priority** section above the timeline; the timeline
  below keeps capture order and omits them (anti-goal: don't reorder the log).
- `Review.queue`: own pending tasks with priority first (stable within each group), then stale waiting.

### Capture parser additions
- A standalone `!` token → `isPriority = true`.
- `every:day`, `every:weekday` (alias `every:weekdays`), `every:week`, `every:month` → `repeatRaw`.
  Unknown `every:` values are kept as text. Trailing punctuation stripped like names.
- `#tag` behaviour unchanged.

## Screens

### Search
- **iPhone:** third tab "Search" (Today · People · Search). **Mac:** sidebar item "Search" plus a
  **Tags** sidebar section listing the top tags (tap = search `#tag`).
- `.searchable` field, prompt "Search everything". Results grouped by day (serif day headers, newest
  first), rows are `EntryRow` with person tap → person page; tap a row → the entry editor.
- **Empty query (browse):** quick filters as chips — Open · Priority · Repeating · Waiting — which
  fill the query (`is:priority` …), then **Tags** as a wrapping chip cloud with counts.
- Typing `#` or `@` shows the existing completion strip pattern for tags/people.
- Empty results: "Nothing matches" with the query echoed.

### Rows (`EntryRow`)
- Meta line gains: `★` when priority (ink, accessibility "Priority"), `↻` when repeating
  ("Repeats weekly"), checklist progress `2/5`, and up to two `#tags` (tap = open Search with that tag;
  more shown as `+2`).

### Entry editor
- New sections: **Priority** toggle; **Repeat** picker (Never / Daily / Weekdays / Weekly / Monthly);
  **Tags** text field (space/comma separated, parsed with `Tags.parse`); **Checklist** — list of items
  with tick buttons, inline add field ("Add item"), swipe/delete, drag to reorder (iOS `onMove`, Mac
  drag); all 44pt targets.

### Day page
- Priority section (only when non-empty) above the timeline: "Priority" caption header, starred open
  tasks.
- Context menu + leading swipe: **Star / Unstar**. Context menu: **Stop repeating** on repeating
  tasks.
- Closing a repeating task shows nothing extra; the next one simply appears on its day.

### Review
- Card shows ★ and ↻ when set and checklist progress. No new actions.

## Error handling & sync
- All fields additive → automatic migration. **Before TestFlight: deploy schema (ChecklistItem +
  new Entry fields) to CloudKit production.**
- Recurrence duplicates from offline closes are removed by `Maintenance.tidy` on foreground.
- Deleting an entry cascades its checklist items.
- Parser never drops unknown `every:` or `!word` tokens (only a bare `!` is special).

## Testing
Swift Testing in `DayfoldCore/Tests`:
- Search: AND tokens, `#tag`, `@person` (linked and `from` text), each `is:` filter, diacritics,
  checklist text, ordering, day grouping.
- Tags: counts, normalization/display spelling, `parse`.
- Recurrence: each rule; weekdays skipping weekend; weekly anchor; monthly clamping (31st → Feb →
  Mar keeps 31 where possible); late close gives next future date; spawn copies fields, unchecked
  checklist, delegated link + new delegatedAt, dueOn shift; notes and one-offs don't spawn;
  `apply(.done/.drop, context:)` spawns, context-free doesn't; dedupe keeps oldest.
- Priority: day page split (priority section vs timeline), Review queue order.
- Parser: `!`, `every:` variants, unknown `every:` kept, punctuation.
UI: extend `DemoData` (priority, a weekly + a daily repeating task, a checklist, several tags) and
the screenshot pass (iPhone light/dark/AX/SE) incl. a new `-search` debug flag for the Search tab.

## Left to the builder
Exact visual spacing, icon choices within SF Symbols that exist on iOS 17 / macOS 14, chip layout
implementation, completion-strip reuse details.
