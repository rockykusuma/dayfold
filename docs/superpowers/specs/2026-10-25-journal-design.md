# Journal — design

Date: 2026-10-25 · Status: owner asked for the journaling round, then "inspire from Apple Journal
application", then said "proceed" to this proposal: Journal tab with entry cards and a + button; real
entries (many per day, optional title, any length, up to 4 photos, bookmark); writing suggestions drawn
from your own day plus a few prompts; Insights at the top (month calendar with dots and soft busy-day
shading, entries this year, days written this month, the Week review one tap away; **no streaks**);
filters All / Bookmarked / With photos; entries in Search and on each Day page; optional Face ID lock;
existing day notes move into entries automatically. Everything below that list is Claude's call.

Follows: `2026-10-25-journal-insights-design.md` (Week page, DayNote). This round supersedes DayNote.

## Why

The one-line daily note proved the idea, but Dayfold's log only says *what* happened. A journal lets the
owner say how it went and why, next to the work itself, the way Apple Journal does for the rest of life —
with suggestions that come from the day they actually had (who they delivered to, who still owes them).

## Goals

1. **Journal tab** — a calm feed of entry cards, newest first, with Insights on top and a big + to write.
2. **Entries** — any number per day; optional title; free text; up to 4 photos; bookmark; editable date.
3. **Suggestions from your day** when starting an entry, plus a few reflection prompts.
4. **Insights** — month calendar (written-day dots, busy-day shading), two counts, link to the Week page.
5. **Find** — filters (All / Bookmarked / With photos), entries in Search, a day's entries on its Day page.
6. **Privacy** — optional Face ID / Touch ID lock that hides journal content everywhere until unlocked.

## Non-goals

Streaks, word counts, scores; multiple journals; map view; location/music/workout/contacts suggestions
(Apple's JournalingSuggestions framework is iPhone-only and needs an entitlement); audio; rich text;
journaling reminders (the evening Review reminder already exists); export.

## Anti-goals

- Gamification of any kind, including streaks (kept from the previous round despite Apple Journal having them).
- Losing writing: Cancel on a new entry with content, or on an edited entry, asks before discarding.
- Journal content leaving the owner's iCloud: never in Share update / Copy, notifications, or Services.
- Locked journal content visible anywhere while locked (feed, Day page, Search, Week page, Review prefill).
- Breaking CloudKit sync rules or losing existing day notes on upgrade.

## Constraints

As the app: iOS 17 / macOS 14 one codebase; SwiftData + CloudKit (defaults/optionals, no unique, raw
enums, optional inverse relationships, additive schema — `DayNote` stays in the schema); logic in
`DayfoldCore` with Swift Testing tests; views thin; Apple frameworks only (PhotosUI, ImageIO,
LocalAuthentication); calm style (ink, paper, card, serif titles/dates, 44pt, Dynamic Type, Reduce Motion).

## Data model (DayfoldCore) — additive

`JournalEntry` (@Model): `id: UUID = UUID()`, `date: Date = Date()` (when it happened; editable),
`title: String = ""`, `text: String = ""`, `isBookmarked: Bool = false`, `isReflection: Bool = false`
(the evening Review line), `createdAt: Date = Date()`, `updatedAt: Date = Date()`,
`photos: [JournalPhoto]?` (cascade, inverse `\JournalPhoto.entry`).
Helpers: `sortedPhotos` (by `order`), `hasPhotos`, `isBlank` (title, text trimmed empty and no photos),
`preview` (title if non-empty else first line of text).

`JournalPhoto` (@Model): `id: UUID = UUID()`, `@Attribute(.externalStorage) data: Data?`,
`order: Double = 0`, `createdAt: Date = Date()`, `entry: JournalEntry?`.

**Before TestFlight: deploy `JournalEntry` and `JournalPhoto` to the CloudKit production schema.**

## Rules (DayfoldCore, tested)

### `Journal`
- `reflection(for day:, calendar:, in:) -> JournalEntry?` — the `isReflection` entry on that calendar day
  (oldest `createdAt` if several).
- `setReflection(_ text:, for day:, now:, calendar:, in:)` — the old `DayNotes.set` contract moved here:
  trims; empty deletes that day's reflection entries; else updates text + `updatedAt` or inserts
  `JournalEntry(date: day at 21:00, text:, isReflection: true)`. Does not save.
- `migrateDayNotes(in:)` — every `DayNote` becomes `JournalEntry(id: note.id, date: note.day at 21:00,
  text: note.text, isReflection: true, createdAt/updatedAt: note.updatedAt)`, then the DayNote is deleted.
  Reusing the note's id lets dedupe collapse copies two devices make offline.
- `dedupe(calendar:, in:)` — (a) entries sharing an `id` (offline migration copies): keep the one with
  the newest `updatedAt` (it holds the latest edit; on a tie the copies are identical, keep either),
  delete the rest; (b) several `isReflection` entries on one
  calendar day: merge exactly like the old `DayNotes.dedupe` (keep oldest, distinct non-empty texts joined
  by "\n" in `updatedAt` order, newest `updatedAt`). Non-reflection entries are never merged by day.
- `Maintenance.tidy`: `migrateDayNotes` then `dedupe` (replacing `DayNotes.dedupe`), then save.

### `JournalInsights`
`JournalInsights(entries: [JournalEntry], tasks: [Entry], month containing: Date, today: Date, calendar:)`
- `month: DateInterval` (`dateInterval(of: .month)`); `title` left to the view.
- `weeks: [[CalendarDay?]]` — rows of 7 starting at `calendar.firstWeekday`; `nil` pads before the 1st
  and after the last day. `CalendarDay`: `date`, `day: Int`, `doneCount` (tasks `.done` with `closedAt`
  that day), `hasEntry` (any journal entry dated that day), `isToday`, `isFuture` (after `today`).
- `level(for doneCount:) -> Int` — 0 for 0, 1 for 1–2, 2 for 3–5, 3 for 6+.
- `entriesThisYear` (entries dated in `today`'s calendar year), `daysWrittenThisMonth` (distinct days in
  `month` with an entry).

### `JournalSuggestions`
`JournalSuggestions.make(tasks: [Entry], day: Date, now: Date = Date(), calendar:) -> [JournalSuggestion]`,
`JournalSuggestion { id: String; title: String; detail: String; kind: .fromYourDay | .prompt }`.
From your day (in this order, each only when it applies, at most 3):
1. Done that day ≥ 1 → title "You finished N thing(s)" (singular "thing" for 1), detail
   "Including “text”" + " for Name" when the most recent one has a person.
2. Oldest waiting (own `to` link, with a person) ≥ 3 days → title "Name has owed you this for Nd", detail "“text”".
3. Oldest own open task already showing (`showOn` ≤ day) with age ≥ 3 → title "Open for Nd", detail "“text”".
4. A task captured that day with a `from` person → title "Name asked you today" when `day` is `now`'s day,
   "Name asked you" for a past day; detail "“text”".
Then 3 prompts chosen from this fixed list by `dayOfYear % count` (rotating, deterministic):
"What made today good?", "What's on your mind for tomorrow?", "Who helped you today?",
"What did you learn today?", "What would you do differently?", "What are you grateful for?".
Picking a suggestion sets the new entry's title to its `title` (prompts: the prompt text) and focuses the body.

### Search
`Search.journal(_ entries: [JournalEntry], query:) -> [JournalEntry]` — plain-word tokens only, AND,
normalized substring over title + text; any `#`, `@` or `is:` token → `[]` (those filters are about
tasks). Newest `date` first. Empty query → `[]`.

### Week page
`WeekReview.notes` becomes `entries: [JournalEntry]` dated in the week (by `date`), oldest first.

## Screens

### Journal tab (`JournalView`)
- **iPhone:** the fourth tab becomes "Journal" (`book.closed`), replacing "Week". **Mac:** sidebar
  "Journal" replaces "This week". DEBUG `-journal` (and `-week` keeps opening the Week page inside it).
- **Insights card** (top, `Color.card`): serif month title ("October 2026") with ‹ › (› disabled on the
  current month); weekday initials; the calendar grid — each day a circle with its number, filled with
  the accent at opacity 0 / 0.12 / 0.24 / 0.4 by `level`, today ringed, future days dimmed, a small dot
  under days with an entry. Tap a day with entries → the feed filters to that day ("Showing Thu 22 ×").
  Below: "N entries this year · N days written this month" and a "This week" row (chevron) that pushes
  the existing Week page. Accessibility label per day: "Thursday 22 October, 3 done, has entries".
- **Filter chips:** All · Bookmarked · With photos.
- **Feed:** month section headers (serif); entry cards (`Color.card`, rounded): date line
  ("Thursday, 22 Oct · 21:00" caption), title (serif semibold) when set, text up to 4 lines, photos as up
  to 4 square thumbnails in a row, a filled bookmark glyph when bookmarked, and a small "Evening
  reflection" caption for `isReflection`. Tap → editor. Context menu (both platforms) + swipe (iPhone):
  Bookmark/Remove bookmark, Delete (confirmation "Delete this entry?").
- **+ button:** a 56pt ink circle, bottom centre, above the tab bar (iPhone); toolbar "New Entry" on Mac
  (⌥⌘N). Opens the editor for a new entry dated now.
- **Empty:** serif "Your journal is empty" + "Tap + to write about your day."

### Entry editor (`JournalEditor`, sheet)
Works on a draft; nothing is written until Done. Fields: compact date+time picker; title
(`TextField`, serif, "Title"); body (`TextEditor`, placeholder "Write about your day…", min ~8 lines);
photos row: thumbnails with a remove button each + `PhotosPicker` ("Add Photos", up to 4 total); toolbar
bookmark toggle, Cancel, Done. New entry: a **Suggestions** section above the fields while title and text
are empty — "From your day" cards then "Prompts" cards; tapping fills the title and focuses the body.
Done on a blank new entry inserts nothing; Done on an existing entry that is now blank asks "Delete this
entry?". Saving a reflection with its date moved to another calendar day turns it into an ordinary entry
(`isReflection = false`), so it never merges into that day's reflection. Photos that can't be loaded, decoded or fit
under the cap show a caption under the photos row, "Couldn't add 1 photo" / "Couldn't add N photos", cleared on the
next pick. Cancel with changes asks "Discard changes?". Photos are downscaled on import to max 2048 px
(ImageIO thumbnail, JPEG 0.8) and stored as `JournalPhoto.data`.

### Elsewhere
- **Day page:** *(removed 2026-10-25 — the owner wants the journal only in its own tab; the Day page shows no journal content.)* Originally: a "Journal" section after the timeline listing that day's entries as compact rows
  (preview text, bookmark glyph, photo glyph), tap → editor; today and past days show "Write about this
  day" (opens a new entry dated that day at the current time, or noon for past days).
- **Search:** a "Journal" section above the task results when `Search.journal` matches; tap → editor.
- **Review:** the "How did today go?" field now reads/writes via `Journal.reflection` /
  `setReflection`.
- **Week page:** its Notes section lists the week's journal entries (preview), tap → editor; "Add a note
  for today" becomes "Write about today" (new entry).

### Lock
- Settings ▸ Journal ▸ "Lock with Face ID" (label uses the device's biometry: Face ID / Touch ID /
  "Lock with passcode" when none). Default off. `@AppStorage("journal.lock")`.
- `JournalLock` (@Observable, shared): `isUnlocked`; `unlock()` uses `LAContext.evaluatePolicy(
  .deviceOwnerAuthentication, localizedReason: "Unlock your journal")`; relocks when the app goes to the
  background. Turning the toggle on requires one successful authentication.
- With no device passcode (`canEvaluatePolicy(.deviceOwnerAuthentication)` is false) nothing could ever unlock it, so
  the lock reads as off (nothing hidden), `unlock()` succeeds, and the toggle is disabled with the footer "Set a
  device passcode to lock your journal." The toggle shows the tapped value while its prompt is up and settles on the
  result (reverting after a failed or cancelled prompt). The label keeps naming Face ID / Touch ID while biometry is
  temporarily locked out.
- While locked: Journal tab shows a centred lock glyph + "Journal locked" + "Unlock" button; the Day page
  Journal section, Search's Journal section and the Week page Notes section are hidden; Review hides the
  reflection field. Info.plist gains `NSFaceIDUsageDescription` = "Dayfold uses Face ID to unlock your
  journal."

## Testing (Swift Testing, `ist` calendar)
- Models: cascade delete of photos; `isBlank`, `preview`, `sortedPhotos`.
- `Journal`: setReflection insert/update/trim/empty clears text and deletes only blank entries/empty-no-op; reflection(for:) by calendar
  day; migrateDayNotes converts text/date/id and deletes the DayNote; dedupe by id; reflection merge;
  plain entries on the same day never merged; tidy runs migrate + dedupe.
- `JournalInsights`: grid shape for Sunday-first and Monday-first (Oct 2026: 1st is a Thursday);
  doneCount and levels; hasEntry; isToday/isFuture; entriesThisYear; daysWrittenThisMonth; February.
- `JournalSuggestions`: each rule with exact titles/details, singular/plural, cap of 3, prompt rotation
  deterministic by day, nothing from your day on an empty day → prompts only.
- `Search.journal`: AND words, diacritics, title and text, token kinds excluded, order.
- `WeekReview` notes → journal entries in week.
UI: DemoData gains entries (several days, one with a title and bookmark, one reflection, two with
generated solid-colour photos), screenshot pass on iPhone 16 Pro and SE.

## Left to the builder
Exact card spacing, thumbnail size, calendar cell size (≥ 36pt circles, row tap targets ≥ 44pt), chip
styling, editor layout on Mac (sheet min size), how the + button avoids the tab bar.
