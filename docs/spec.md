# Dayfold — v0.1 Spec

Mac + iPhone. SwiftUI, SwiftData + CloudKit (private database). Open source, MIT.

## Problem

R leads two teams. Requests arrive all day from many people and channels. Writing them
in Apple Notes failed because nothing re-surfaces them: the forgetting happens at review
time, not capture time. Dayfold is a digital bullet journal whose core feature is the
evening Review that folds unfinished work into tomorrow.

## Model

One entity, `Entry` (see `DayfoldCore/Sources/DayfoldCore/Entry.swift`).

| Field | Meaning |
|---|---|
| `createdAt` | Capture time. The timestamp shown on the page. |
| `kind` | `task` (carries forward) or `note` (journal; belongs to its day). |
| `text` | Free text. |
| `scope` | `work` / `personal`. A filter, not a partition. |
| `status` | `open`, `inProgress`, `done`, `dropped`. `open`+`inProgress` = active. |
| `closedAt` | Set when status becomes `done` or `dropped`. |
| `showOn` | First day the task appears. Defaults to capture day. Review's "push" moves it. |
| `dueOn` | Optional. |
| `from` | Optional. Who asked. |
| `tags` | Optional. |

CloudKit constraints: every property has a default or is optional; no unique attributes;
enums stored as raw strings.

## Day page rule (the carry-forward)

A day page is a query, not storage. For day **D**:

- A **note** is on D iff `createdAt` ∈ D.
- A **task** is on D iff `showOn ≤ D` and
  - it is active (open / inProgress), **or**
  - it was closed on D (`closedAt` ∈ D).

Consequences: an active task is on every page from `showOn` onward until closed; a
closed task appears only on the day it was closed; a past day shows exactly what was
open then. Age badge = whole days between `createdAt` and D.

Encoded and tested in `DayPage.swift` / `DayPageTests.swift`.

## Review (the forgetting fix)

Local notification at a configurable time (default 18:30, weekdays). Opens Review:
one card per task in `Review.pending(on: today)` — active and visible today.
Four actions per card:

| Action | Effect |
|---|---|
| Done | `status = done`, `closedAt = now` |
| Still going | `status = inProgress` (carries to tomorrow) |
| Push to… | `showOn = chosen day` (hidden until then) |
| Drop | `status = dropped`, `closedAt = now` |

Finishing Review leaves tomorrow's page already correct. Review can also be opened
manually at any time. Undo: `Review.reopen` clears status and `closedAt`.

## Screens (v0.1)

1. **Today** — day page for today. Timestamped rows; tasks have a check circle, notes
   don't. Scope toggle at top: Work / Personal / Both. Age badge on tasks older than
   today. Swipe/context actions: Done, Push to tomorrow, Drop, Edit.
2. **Capture** — single text field pinned to the bottom (iPhone) / ⌘N sheet and
   menu-bar item (Mac). Kind defaults to task; a leading `>` or a segmented control
   makes it a note. Light parser (optional): `#personal`, `@fri` / `@2026-10-24`
   (dueOn), `from:priya`.
3. **Review** — card stack described above. Entered from the notification or a
   toolbar button. Shows progress (3 of 7).
4. **Day browser** — swipe/arrow between days; calendar picker. Past days read-only
   except reopening a task.
5. **Settings** — review time and days, default scope, notification permission,
   iCloud status, Markdown export folder (v0.3).

## Not in v0.1

Recurring tasks, search, widgets, Siri/App Intents, share extension, Markdown export,
long-form journal view. (v0.2–v0.3; see README roadmap.)

## Decisions log

- 2026-10-18 Mac + iPhone only; web and Android/Windows dropped for now.
- 2026-10-18 SwiftData automatic CloudKit sync (not CKSyncEngine) — no web client to
  share a schema with.
- 2026-10-18 Markdown export kept as the lifelong-data guarantee.
- 2026-10-18 Review wizard is in v0.1, not deferred.
- 2026-10-18 Push Notifications capability deferred; `aps-environment` removed from
  entitlements until then. Sync is pull-on-foreground meanwhile.
- 2026-10-18 Bundle id `com.rockykusuma.dayfold.app`; container `iCloud.com.rockykusuma.dayfold`.
- 2026-10-18 Push Notifications capability enabled (`aps-environment` development, iOS + macOS).
  Live sync via CloudKit silent pushes verified Mac ↔ iPhone. No refresh button: SwiftData
  has no public "fetch now" API; push is the mechanism.
- 2026-10-18 People & delegation: Person model (role, optional team) linked one-per-entry
  via from / to / about; to:name + Delegate action; stale waiting items join evening
  Review after N days (default 3). iPhone tabs, Mac sidebar. Spec:
  docs/superpowers/specs/2026-10-18-people-delegation-design.md
- Before the first TestFlight build: deploy the CloudKit schema (Person + new Entry fields)
  to production in the CloudKit Console.
- 2026-10-19 Find & organise: search (AND tokens, #tag, @person, is: filters), visible tags,
  checklists (ChecklistItem model), repeating tasks (daily / weekdays / weekly:<weekday> / monthly:<day>;
  next occurrence spawned on done/drop, never catch-up copies; dedupe on foreground),
  single-level priority (Priority section above the timeline, starred first in Review).
  Spec: docs/superpowers/specs/2026-10-19-find-organise-design.md
- 2026-10-19 `!` and `every:` typed on a note capture are dropped (priority/repeat are tasks-only).
- 2026-10-19 Spawned occurrences are dated to their own day (createdAt = showOn + original time of
  day) so they never look old; a re-delegated copy's waiting clock starts then too.
- 2026-10-19 Weekly repeats are anchored like monthly (`weekly:<weekday>`, 1 = Sunday, set from
  `showOn` when chosen), so pushing one occurrence doesn't move the series. Bare `weekly` still parses.
- Before the first TestFlight build: deploy the CloudKit schema (ChecklistItem + Entry
  isPriority / repeatRaw / seriesID / checklist) to production in the CloudKit Console.
- 2026-10-25 Capture everywhere: every entry point (bar, ⌘N, App Intent, hotkey panel, Services)
  goes through one Core path, `Capture.add` / `addLines`. ⌘N "New Entry" replaces File ▸ New.
  Pasting or dropping a multi-line list splits into one entry per line (markers stripped).
  App Intent and Services use the last-used scope (`capture.lastScope`, default work) and today.
  Mac global hotkey presets ⌃⌥Space / ⌃⌥D via Carbon, default set in Settings. Services menu
  "Add to Dayfold" via `NSServices` + `NSApp.servicesProvider`. Share extension and widgets
  deferred (need new targets + an App Group). Spec: docs/superpowers/specs/2026-10-25-capture-everywhere-design.md
- Quick-capture hotkey default is ⌃⌥D, not ⌃⌥Space: ⌃⌥Space is macOS's "Select next source in Input menu" and wins on Macs with 2+ input sources (overrides the design doc).
- 2026-10-25 Journal & insights: Week page (Done by person, Stuck, Waiting on, day notes, Share update /
  Copy), one-line `DayNote` per day from Review or the Week page. The week follows the locale's first weekday
  (`dateInterval(of: .weekOfYear)`). Stuck = open own tasks with age ≥ 3 (the amber threshold). Stuck and
  Waiting on show only for the current week; past weeks show Done, the dropped count and notes. Day notes are
  never in the update text. Same-day notes from two devices are merged by `Maintenance.tidy`. No streaks,
  scores or percentages. Spec: docs/superpowers/specs/2026-10-25-journal-insights-design.md
- Before the first TestFlight build: deploy the CloudKit schema (DayNote) to production in the CloudKit Console.
- 2026-10-25 Update text (Share/Copy) lists work-scoped entries only; the Week page itself shows everything.
- 2026-10-25 Week page browses by a week offset from now (not a stored date), so it stays correct across midnight.
- 2026-10-25 Recommend First Day of Week = Monday (Language & Region) on iPhone and Mac; the week follows the locale.
- 2026-10-25 Journal (Apple Journal-inspired): `JournalEntry` (+ `JournalPhoto`) supersedes `DayNote`. `Maintenance.tidy`
  migrates every DayNote into an `isReflection` entry (same id, 21:00 that day) and deletes it, then dedupes by id
  (offline copies from two devices) and merges same-day reflections. `DayNote` stays in the schema (additive only).
- 2026-10-25 No streaks, even though Apple Journal has them; no word counts or scores either.
- 2026-10-25 Writing suggestions come from your own day (done, waiting, open, asked today) plus rotating prompts;
  no JournalingSuggestions framework (iPhone-only, needs an entitlement).
- 2026-10-25 Journal lock (Settings ▸ Journal, off by default; turning it on needs one successful Face ID / Touch ID /
  passcode check) gates everything: Journal tab shows "Journal locked" + "Unlock"; Day page Journal section, Search
  Journal section, Week page Notes and the Review reflection field are hidden. Relocks when the app goes to the
  background (Mac: when it resigns active); while inactive the content is only covered (app-switcher snapshot), since
  the auth prompt itself makes the app inactive. Turning the lock off while locked needs a successful unlock. The lock is a cover, so an open
  editor keeps its draft. Journal content is never in Share update / Copy, notifications or Services.
- 2026-10-25 Photos are downscaled on import to a 2048 px long side (JPEG 0.8), up to 4 per entry, external storage.
- 2026-10-25 The Journal feed's filter (All / Bookmarked / With photos, plus a calendar day) and month grouping are Core rules
  (`JournalFeed`); the view only draws them. Paging the Insights month clears the day filter.
- 2026-10-25 Photos that fail to load or decode (or exceed the 4-photo cap) are never dropped silently: the editor shows
  "Couldn't add 1 photo" / "Couldn't add N photos" under the photos row until the next pick.
- 2026-10-25 Lock label follows the device's biometry type even while biometry is temporarily locked out; with no device
  passcode the lock can't be turned on (toggle disabled, "Set a device passcode to lock your journal.") and reads as off.
- 2026-10-25 The lock toggle shows the tapped value while the auth prompt is up and settles on the result (reverts on
  failure or cancel), instead of flicking back and forth.
- Before the first TestFlight build: deploy the CloudKit schema (JournalEntry, JournalPhoto) to production in the CloudKit Console.
- 2026-10-25: Journal lives only in its own tab — the Day page shows no journal section (owner request). Search, the Week page and Review's reflection field still use journal entries.
