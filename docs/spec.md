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
