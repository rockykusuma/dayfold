# People & delegation — design

Date: 2026-10-18 · Status: approved in brainstorming, awaiting spec review
Part of the post-v0.1 roadmap: (1) app icon ✅ → **(2) People & delegation** → (3) Find & organise → (4) Capture everywhere → (5) Journal & insights.

## Why

R leads two teams. Requests come from many people, and R hands work to others. Today Dayfold
records *who asked* as free text (`from:priya`) and has no notion of work R is waiting on.
The forgetting problem Dayfold solves for R's own tasks also exists for delegated work and
for 1:1 preparation.

## Goals

1. **What I owe whom** — everything a person asked for, across days, in one place.
2. **Waiting on others** — track work R delegated until the other person delivers.
3. **1:1 prep** — before a 1:1, see open items both ways plus running notes about that person.
4. **Follow-up nudges** — stale waiting items surface in the evening Review.

Success: on R's Mac and iPhone, opening a person shows owe / waiting / notes correctly; a
delegated item reappears in Review after N days without R remembering it; nothing in
existing data is lost or duplicated by the upgrade.

## Non-goals (this project)

Contacts integration, avatars/photos, per-person notifications, recurring 1:1 scheduling,
search (project 3), widgets/Siri/share sheet (project 4), team-level analytics (project 5).

## Decisions (from brainstorming)

| Topic | Decision |
|---|---|
| People organisation | Teams + roles. Role ∈ report / manager / peer / other; team is optional free text. People auto-created from capture. |
| Delegation capture | `to:name` syntax + **Delegate to…** action on existing tasks. |
| Nudges | Inside the evening Review only; stale after N days (default 3, setting 1–14). |
| Navigation | iPhone: tab bar (Today · People). Mac: sidebar (Today, People, Teams, All waiting). |
| Data model | `Person` @Model + one optional link per `Entry` (approach 1). |

## Data model (DayfoldCore)

CloudKit rules still apply: every stored property has a default or is optional, no
`@Attribute(.unique)`, enums stored as raw strings, relationships optional with inverses.

### `Person` (new @Model)

| Field | Type | Default | Notes |
|---|---|---|---|
| `id` | `UUID` | `UUID()` | |
| `name` | `String` | `""` | Display name as typed, e.g. "Priya Sharma". |
| `roleRaw` | `String` | `"other"` | `PersonRole`: `report`, `manager`, `peer`, `other`. |
| `team` | `String?` | `nil` | Free text; distinct values form the team list. |
| `createdAt` | `Date` | `Date()` | Oldest wins on merge. |
| `isSorted` | `Bool` | `false` | Set `true` when R saves the Edit sheet. `false` = shown under Unsorted. |
| `entries` | `[Entry]?` | `nil` | Inverse of `Entry.person`, delete rule `.nullify`. |

### `Entry` additions (all optional; existing fields unchanged)

| Field | Type | Meaning |
|---|---|---|
| `person` | `Person?` | Linked person. |
| `linkRaw` | `String?` | `PersonLink`: `from` (they asked me), `to` (I'm waiting on them), `about` (1:1 note). |
| `delegatedAt` | `Date?` | When the entry became waiting (`link = to`). |
| `nudgedAt` | `Date?` | Last follow-up. |

The legacy `from: String?` stays. It is display text only once a `person` is linked.

A **waiting item** is an `Entry` with `kind == .task`, `link == .to`, `status.isActive`.
It is a task, so `DayPage.contains` carries it forward unchanged.

### Protocol

`DayPageItem` gains `link: PersonLink?`, `delegatedAt: Date?`, `nudgedAt: Date?` so rules
stay testable with plain structs.

## Rules (DayfoldCore, pure, Swift Testing)

### `PeopleDirectory`

- `normalize(_ name:) -> String`: trim, `_` → space, collapse spaces, case- and
  diacritic-insensitive fold. "priya", " Priya ", "PRIYA" are equal.
- `match(_ typed:, in people:) -> Match`:
  1. exact normalized match → `.existing(person)`;
  2. else exactly one person whose normalized name starts with the typed token → `.existing`;
  3. else → `.new(name: typed with "_" → " ", first letter capitalised)`.
  Ambiguous prefixes (two "Priya…") with no exact match → `.new`, which lands in Unsorted.
- `findOrCreate(_ typed:, in context:) -> Person`.
- `mergeDuplicates(in context:)`: group by `normalize(name)`; keep the oldest `createdAt`;
  move every entry of the others to it; copy `team` / non-`other` role / `isSorted` if the
  keeper lacks them; delete the others. Idempotent.
- `delete(_ person:, in context:)`: for every linked entry set `link = nil` (waiting items
  become R's own tasks again; `delegatedAt`/`nudgedAt` kept as history), then delete the
  person (relationship nullifies).
- `backfillFromText(in context:)`: for entries with non-empty `from` text and `person == nil`,
  `findOrCreate(from)` and set `link = .from`. Idempotent.

### Person page queries

- `owed(to p)`: active tasks with `person == p`, `link == .from`, oldest first.
- `waiting(on p)`: active tasks with `person == p`, `link == .to`, oldest first.
- `notes(about p)`: notes with `person == p`, `link == .about`, newest first.
- `allWaiting`: every waiting item, grouped by person.
- Counts for list badges: owed count, waiting count, oldest waiting age (days).

### Review

- `Review.pending(on: day)` (own tasks) **excludes** waiting items.
- `Review.staleWaiting(on: day, after n: Int)`: waiting items where
  `days(since: nudgedAt ?? delegatedAt ?? createdAt) ≥ n`, oldest first.
- Review queue = own pending tasks, then stale waiting items.
- New `ReviewAction` case `.nudged` → `nudgedAt = now` (status unchanged).
- `Review.delegate(_ entry:, to person:, now:)` → `person = p`, `link = .to`,
  `delegatedAt = now`, status `open`. A function rather than an enum case because
  `ReviewAction` is `Sendable` and `Person` is a model object.
- Existing actions on a waiting item: Got it = `.done`, Follow up on… = `.push(to:)`, Drop = `.drop`.

## Capture

Shared `CaptureBar` — applies to iPhone, Mac window and Mac menu-bar panel.

- `CaptureParser` adds `to:name` → `ParsedCapture.to: String?` (mirrors `from:`). Empty
  names (`to:`) are kept as text, like `from:` today.
- On save: if `to` present → `findOrCreate`, `link = .to`, `delegatedAt = now`. Else if
  `from` present → `findOrCreate`, `link = .from`. Only one person per entry; when both are
  typed, `to:` wins and `from` stays as text.
- **Autocomplete:** while the token under the cursor starts with `from:` or `to:`, show a
  suggestion strip above the field (recent people first, prefix match, max 5). Tapping
  replaces the token with the person's name using `_` for spaces.
- **Person-page capture:** the bar is pre-linked to that person with a segmented
  **I owe / Waiting / 1:1 note** control (`from` / `to` / `about`; 1:1 note forces
  `kind = .note`).
- **Delegate to…** (day page swipe + context menu; Review "Push to…" menu): opens a people
  picker sheet — search field, recent people, "Add '<typed>'" — then calls `Review.delegate`.

## Review UI

- Single card stack: own tasks, then a divider card "Waiting on others · N", then stale
  waiting cards. Progress counts both.
- Toolbar badge = own pending + stale waiting.
- **Waiting card:** header "⇢ Waiting on Arjun · 4d" + team; text in serif. Actions:
  **Got it** (primary), **Nudged today**, **Follow up on…** (Tomorrow / Next Monday / Pick a
  date), **Drop** (quiet red), and a small **Message…** `ShareLink` with
  "Hi Arjun, checking in on: <text>" — sharing also applies `.nudged`.
- Own-task cards: **Push to…** menu gains **Delegate to…**.
- End tally includes delegated and nudged counts.
- Settings → Evening review: **Nudge after** stepper, 1–14 days, default 3
  (`@AppStorage("review.nudgeAfter")`).

## Screens

- **Navigation:** iPhone `TabView` (Today, People). Mac `NavigationSplitView` sidebar:
  Today, People, Teams (one row per distinct team), All waiting. Day page unchanged inside.
- **People list:** sections Direct reports / Manager / Peers & others; team filter (All +
  each team); per-row badges: "N owe", "N waiting · oldest Nd" (amber). "Unsorted · N"
  entry lists people with `isSorted == false` (auto-created from capture, never edited);
  they also appear in their role section.
- **Person page:** kicker "Team · role", serif name, summary line; sections You owe / Waiting
  on / 1:1 notes; capture bar with link control; **Edit** sheet: name, role, team, **Merge
  with…** (pick another person → move entries, delete), **Delete** (confirm: entries stay,
  unlinked; uses `PeopleDirectory.delete`).
- **Day page:** waiting rows use mark ⇢ (amber), person name in the meta line; tapping it
  opens the person page. `from` rows show the person name the same way.
- **All waiting (Mac sidebar / iPhone People tab section):** every waiting item grouped by
  person with ages.

## Error handling & sync

- Schema change is additive (new model + optional fields) → automatic migration. **Before
  the first TestFlight/App Store build: deploy the CloudKit schema to production in the
  CloudKit Console.**
- `mergeDuplicates` + `backfillFromText` run at launch and on `scenePhase == .active`.
- Person delete uses `.nullify`; entries survive.
- Parser never drops text it can't use.

## Testing

Swift Testing in `DayfoldCore/Tests` (in-memory `ModelContainer` where SwiftData is needed):

- `normalize` / `match`: exact, unique prefix, ambiguous prefix, underscores, diacritics.
- `CaptureParser`: `to:`, `from:`, both, empty name, underscores.
- `mergeDuplicates`: keeps oldest, moves entries, copies team/role/isSorted, idempotent.
- `delete`: entries survive with `link == nil`; waiting item becomes an own task in `Review.pending`.
- `backfillFromText`: links once, idempotent, ignores empty text.
- Person queries: owed / waiting / notes filters and ordering.
- Review: waiting excluded from `pending`; `staleWaiting` threshold incl. `nudgedAt` reset;
  `.nudged` and `Review.delegate` effects; queue order.

UI: extend `DemoData` with people across both teams, owed items, waiting items (one stale,
one nudged), 1:1 notes. Screenshot pass: iPhone light/dark, largest Dynamic Type, iPhone SE,
Mac window.

## Open for later

Contacts linking and avatars; per-person 1:1 cadence reminders; search across people
(project 3); a "waiting" widget (project 4).
