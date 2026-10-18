# Find & Organise Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add search, visible tags, checklists, repeating tasks and priority to Dayfold on iPhone and Mac.

**Architecture:** Additive SwiftData fields on `Entry` plus a new `ChecklistItem` model. Every rule (recurrence dates, spawning the next occurrence, dedupe, search matching, tag counting, checklist ordering, priority split) is in `DayfoldCore` with Swift Testing tests. Closing a repeating task inserts the next occurrence through a new `Review.apply(_:to:now:calendar:context:)` overload, and every app close path calls that overload. The app adds row/card badges, editor sections, a Priority section on the day page, and a Search screen (third iPhone tab; Mac sidebar item plus a Tags section).

**Tech Stack:** Swift 5 language mode, SwiftUI (iOS 17 / macOS 14), SwiftData with CloudKit private database, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-10-19-find-organise-design.md`

## Global Constraints

- Deployment targets: iOS 17 / macOS 14, one codebase. Use only APIs available on both.
- CloudKit: every stored property has a default or is optional; no `@Attribute(.unique)`; enums stored as raw strings; relationships optional with inverses. All changes are additive, so migration is automatic.
- Logic lives in `DayfoldCore` with Swift Testing tests. Views stay thin. Carry-forward is a query (`DayPage.contains`), never a copy.
- Anti-goals: the day page never becomes a project board, and the timeline keeps capture order. Recurrence never piles up missed copies.
- `RepeatRule` raw values are `daily`, `weekdays`, `weekly` and `monthly:<day>` (e.g. `monthly:31`). Bare `monthly` is accepted defensively.
- Parser tokens: a standalone `!` sets priority. `every:day`, `every:weekday`, `every:weekdays`, `every:week` and `every:month` set the repeat. Unknown `every:` values and `!word` stay in the text.
- Copy (verbatim): tab and sidebar "Search"; search prompt "Search everything"; chips "Open", "Priority", "Repeating", "Waiting"; section "Tags"; empty results "Nothing matches"; day-page caption "Priority"; actions "Star" / "Unstar" / "Stop repeating"; editor "Priority", "Repeat" (Never / Daily / Weekdays / Weekly / Monthly), "Tags", "Checklist", "Add item".
- SF Symbols (all exist on iOS 17 / macOS 14): `star.fill`, `star`, `star.slash`, `repeat`, `checklist`, `number`, `magnifyingglass`, `stop.circle`, `checkmark.circle.fill`, `circle`.
- Style: ink accent (`.tint`), `Color.paper` backgrounds, `Color.card` surfaces, serif (`design: .serif`) for day headers and empty states, 44pt tap targets, `.snappy` animations, respect Reduce Motion, Dynamic Type through the accessibility sizes.
- Tests: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`. To focus on one suite, add `-only-testing:DayfoldCoreTests/<SuiteStructName>`. Never run `swift test`.
- Both app builds must pass after every task that touches `dayfold/`:
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO`
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
- Every commit message ends with these two trailer lines:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_016KuWvS3f2pThajg7yChjq9`
- New core test files start with `import Foundation`, `import SwiftData`, `import Testing`, `@testable import DayfoldCore`.
- Core tests use the shared `ist` calendar (gregorian, Asia/Kolkata) and the `at(y, m, d, h)` helper from Task 1. 2026-10-19 is a Monday.

## Review Focus

1. **Recurrence across a DST change.** A daily, weekly or weekdays task in New York around 2026-11-01 must land on local midnight of the right day, not 23:00 the day before. The test is in Task 3 (`dst`).
2. **Accidental double close.** If someone ticks a repeating task, undoes it and ticks it again, exactly one next occurrence must exist. The test is in Task 4 (`doubleClose`).
3. **Two devices closing the same first occurrence offline.** Both devices must give the spawned copies the same `seriesID` so that dedupe can merge them. The series id is the first occurrence's `id`, not a random UUID. The tests are in Task 4 (`seriesIDIsDeterministic`, `dedupe`).
4. **Tag spelling variants.** `#Hiring`, `hiring`, `hiring,`, `#hiring.` and `híring` must be one tag in counts and in `#tag` search. The test is in Task 5 (`keyNormalizes`).
5. **Search on a large store.** Querying 5,000 entries per keystroke must finish in under 1 s. The test is in Task 6 (`largeStore`).

## Decisions the plan makes beyond the spec

- `DayPageItem` gains `isPriority` so the priority split and the Review queue stay generic and testable with `FakeItem`. Repeat and series stay on `Entry` only, because only `Entry`-based code reads them.
- `RepeatRule` is `enum { daily, weekdays, weekly, monthly(day: Int?) }` in `Entry.swift`. The parser emits `.monthly(day: nil)`, and `Entry.setRepeat(_:calendar:)` anchors it to the day-of-month of `showOn`.
- `seriesID` is the first occurrence's `id`, written by `setRepeat` and by `spawnNext` when it is nil. That makes it deterministic across devices.
- `spawnNext` does nothing when an active occurrence of the same series with a later `showOn` already exists (done → undo → done).
- A spawned delegated occurrence also clears `nudgedAt`, so it doesn't start out stale.
- "Weekdays" means weekday components 2–6, not `Calendar.isDateInWeekend`, which depends on the locale.
- Tag comparison strips a leading `#` and trailing `.,;:!?)` before normalizing. The parser itself is unchanged.
- The Tags task comes before Search, because Search's `#tag` token uses `Tags.key`.
- Search groups results by the `createdAt` day and keeps result order inside each group. It returns `[SearchDayGroup]`, and Tags returns `[TagCount]`: small `Identifiable` structs instead of tuples, so `ForEach` works.
- A bare `#` or `@` query token is ignored, so results don't flash "Nothing matches" while typing.
- Checklist order: the first item gets 0 and each append gets last + 1. Moving one item writes only that item, at the midpoint between its neighbours. Ties (from concurrent appends) or multi-item moves renumber 0…n-1. Display sorts by `(order, createdAt)`.
- `EntryEditor` moves from `DayPageView.swift` into its own file so that Search can present it.
- `SearchRouter.shared`, an `@Observable` like `ReviewReminder.shared`, holds the search query. It routes tag taps from any row to the Search screen.
- `#` and `@` completions use the native `.searchSuggestions`, not CaptureBar's strip.
- The `-search` debug flag takes an optional query (`-search '#hiring'`), so result screenshots don't need typing.
- The Mac Tags sidebar section shows the top 8 tags.
- Star and Stop repeating appear only for active tasks on today's and future pages, because past pages stay read-only.

## File map

| File | Responsibility |
|---|---|
| `DayfoldCore/Sources/DayfoldCore/Entry.swift` (modify) | `isPriority`, `repeatRaw`, `seriesID`, `checklist`; `RepeatRule`; `repeatRule`, `setRepeat` |
| `DayfoldCore/Sources/DayfoldCore/ChecklistItem.swift` (new) | `ChecklistItem` model; `Checklist` helpers; `Entry.sortedChecklist` / `checklistProgress` |
| `DayfoldCore/Sources/DayfoldCore/DayPage.swift` (modify) | `DayPageItem.isPriority`; `DayPage.prioritySplit` |
| `DayfoldCore/Sources/DayfoldCore/CaptureParser.swift` (modify) | `!` and `every:` |
| `DayfoldCore/Sources/DayfoldCore/Recurrence.swift` (new) | `nextShowOn`, `spawnNext`, `dedupe` |
| `DayfoldCore/Sources/DayfoldCore/Maintenance.swift` (new) | `Maintenance.tidy` |
| `DayfoldCore/Sources/DayfoldCore/Review.swift` (modify) | `apply(…, context:)`; priority-first `queue` |
| `DayfoldCore/Sources/DayfoldCore/PeopleDirectory.swift` (modify) | `tidy` becomes a thin call to `Maintenance.tidy` |
| `DayfoldCore/Sources/DayfoldCore/Tags.swift`, `Search.swift` (new) | tag keys, counts, parse; search matching, ordering, grouping, completion token |
| `DayfoldCore/Tests/DayfoldCoreTests/*` | `TestSupport.swift` plus one suite per task; `FakeItem.isPriority`; `makeContainer` adds `ChecklistItem` |
| `dayfold/MyApp.swift`, `dayfold/DemoData.swift` | schema, `Maintenance.tidy`, demo content |
| `dayfold/Views/CaptureBar.swift` | apply parsed priority and repeat |
| `dayfold/Views/EntryRow.swift`, `ReviewView.swift` | ★ ↻ checklist and tag badges |
| `dayfold/Views/EntryEditor.swift` (new, moved) | editor plus Priority / Repeat / Tags / Checklist sections |
| `dayfold/Views/DayPageView.swift` | Priority section, Star / Stop repeating |
| `dayfold/Views/SearchRouter.swift`, `SearchView.swift` (new) | shared query and routing; Search screen |
| `dayfold/Views/RootView.swift` | Search tab / sidebar item, Tags sidebar section, `-search` |
| `dayfold/Views/MenuBarCapture.swift`, `People/PersonView.swift`, `People/AllWaitingView.swift` | close through the context overload |

---

### Task 1: Model additions — Entry fields, ChecklistItem, RepeatRule

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/Entry.swift` (fields after `nudgedAt`; `RepeatRule` beside the other enums)
- Create: `DayfoldCore/Sources/DayfoldCore/ChecklistItem.swift`
- Modify: `DayfoldCore/Sources/DayfoldCore/DayPage.swift` (protocol)
- Modify: `DayfoldCore/Tests/DayfoldCoreTests/DayPageTests.swift` (`FakeItem` gets `var isPriority: Bool = false` as its **last** property, so existing memberwise calls compile)
- Modify: `DayfoldCore/Tests/DayfoldCoreTests/PeopleModelTests.swift` (`makeContainer()` adds `ChecklistItem.self`)
- Create: `DayfoldCore/Tests/DayfoldCoreTests/TestSupport.swift`, `FindModelTests.swift`
- Modify: `dayfold/MyApp.swift` (`Schema([Entry.self, Person.self, ChecklistItem.self])`), `dayfold/DemoData.swift` (container adds `ChecklistItem.self`)

**Interfaces:**
- Produces:
  - `Entry.isPriority: Bool = false`, `Entry.repeatRaw: String?`, `Entry.seriesID: UUID?`, `@Relationship(deleteRule: .cascade, inverse: \ChecklistItem.entry) Entry.checklist: [ChecklistItem]?`
  - `@Model public final class ChecklistItem { id: UUID = UUID(); text: String = ""; isDone: Bool = false; order: Double = 0; createdAt: Date = Date(); entry: Entry?; init(text: String, order: Double = 0, createdAt: Date = Date()) }`
  - `public enum RepeatRule: Hashable, Sendable { case daily, weekdays, weekly, monthly(day: Int?) }` with `init?(rawValue: String)`, `var rawValue: String`, `var choice: RepeatRule` (drops the monthly day), `var title: String` ("Daily", "Weekdays", "Weekly", "Monthly") and `var summary: String` ("Repeats daily", "Repeats on weekdays", "Repeats weekly", "Repeats monthly")
  - `Entry.repeatRule: RepeatRule?` (get only, parsed from `repeatRaw`); `Entry.setRepeat(_ rule: RepeatRule?, calendar: Calendar = .current)`
  - `DayPageItem.isPriority: Bool { get }`
  - Test support: `let ist: Calendar`; `func at(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0) -> Date`

- [ ] **Step 1: Write the test support and the failing tests**

`TestSupport.swift`:
```swift
import Foundation

/// Gregorian, Asia/Kolkata (no DST). 2026-10-19 is a Monday.
let ist: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
    return c
}()

func at(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0) -> Date {
    ist.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
}
```

`FindModelTests.swift`:
```swift
@Suite("Find & organise model") @MainActor
struct FindModelTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test func newFieldsDefault() {
        let e = Entry(text: "x")
        #expect(e.isPriority == false && e.repeatRaw == nil && e.seriesID == nil && e.repeatRule == nil)
        #expect((e.checklist ?? []).isEmpty)
    }

    @Test func repeatRuleRawValues() {
        for raw in ["daily", "weekdays", "weekly", "monthly:31"] { #expect(RepeatRule(rawValue: raw)?.rawValue == raw) }
        #expect(RepeatRule(rawValue: "monthly") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "monthly:0") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "monthly:x") == .monthly(day: nil))
        #expect(RepeatRule(rawValue: "fortnightly") == nil)
        #expect(RepeatRule.monthly(day: nil).rawValue == "monthly")
        #expect(RepeatRule.monthly(day: 12).choice == .monthly(day: nil) && RepeatRule.weekly.choice == .weekly)
        #expect(RepeatRule.weekdays.summary == "Repeats on weekdays" && RepeatRule.monthly(day: 3).title == "Monthly")
    }

    @Test("Choosing Monthly anchors on showOn's day and starts a series")
    func setRepeatAnchors() {
        let e = Entry(text: "Rent", createdAt: at(2027, 1, 31, 9), calendar: ist)
        e.setRepeat(.monthly(day: nil), calendar: ist)
        #expect(e.repeatRaw == "monthly:31" && e.seriesID == e.id)
        e.setRepeat(nil, calendar: ist)
        #expect(e.repeatRaw == nil && e.seriesID == e.id)
    }

    @Test("Deleting an entry deletes its checklist")
    func checklistCascades() throws {
        let e = Entry(text: "Ship"); context.insert(e)
        for t in ["a", "b"] { let i = ChecklistItem(text: t); context.insert(i); i.entry = e }
        try context.save()
        #expect(e.checklist?.count == 2)
        context.delete(e); try context.save()
        #expect(try context.fetch(FetchDescriptor<ChecklistItem>()).isEmpty)
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/FindModelTests`
Expected: the build fails with `cannot find 'ChecklistItem' in scope`.

- [ ] **Step 3: Implement the model additions as listed in Interfaces**

`RepeatRule.init?(rawValue:)`: `monthly:<n>` becomes `.monthly(day: n)` only when n is in 1...31; any other suffix, and bare `monthly`, becomes `.monthly(day: nil)`. `setRepeat` stores `rule?.rawValue`. When the rule is `.monthly(day: nil)`, it first resolves to `.monthly(day: calendar.component(.day, from: showOn))`. For any non-nil rule it sets `seriesID = seriesID ?? id`. Then add `ChecklistItem.self` to the app's two container sites.

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`. Expected: `** TEST SUCCEEDED **`. Then run both app builds and expect `** BUILD SUCCEEDED **` ×2.

- [ ] **Step 5: Commit**

`git add DayfoldCore dayfold/MyApp.swift dayfold/DemoData.swift && git commit -m "Find & organise: Entry priority/repeat/checklist fields, ChecklistItem model"` (trailers per Global Constraints)

---

### Task 2: Capture parser `!` and `every:`, wired into CaptureBar

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/CaptureParser.swift`
- Modify: `DayfoldCore/Tests/DayfoldCoreTests/CaptureParserTests.swift`
- Modify: `dayfold/Views/CaptureBar.swift` (`save()`)

**Interfaces:**
- Consumes: `RepeatRule`, `Entry.setRepeat(_:calendar:)` (Task 1)
- Produces: `ParsedCapture.isPriority: Bool = false`, `ParsedCapture.repeatRule: RepeatRule? = nil` (both declared after `to`, with defaults, so the existing `ParsedCapture(text:scope:from:dueOn:tags:)` literal still compiles)

- [ ] **Step 1: Write the failing tests** (add them to `CaptureParserTests`)

```swift
@Test func bangMarksPriority() {
    let p = CaptureParser.parse("Ship deck ! #work", now: now, calendar: cal)
    #expect(p.isPriority && p.text == "Ship deck")
    #expect(CaptureParser.parse("Wow!", now: now, calendar: cal).isPriority == false)
    let w = CaptureParser.parse("!urgent fix", now: now, calendar: cal)
    #expect(w.isPriority == false && w.text == "!urgent fix")
}

@Test func everyVariants() {
    func rule(_ s: String) -> RepeatRule? { CaptureParser.parse("x \(s)", now: now, calendar: cal).repeatRule }
    #expect(rule("every:day") == .daily)
    #expect(rule("every:weekday") == .weekdays && rule("every:weekdays") == .weekdays)
    #expect(rule("every:week") == .weekly)
    #expect(rule("every:month") == .monthly(day: nil))
    #expect(rule("every:Week,") == .weekly)
    #expect(CaptureParser.parse("Report every:week", now: now, calendar: cal).text == "Report")
}

@Test func unknownEveryIsKeptAsText() {
    let p = CaptureParser.parse("stretch every:fortnight every:", now: now, calendar: cal)
    #expect(p.repeatRule == nil && p.text == "stretch every:fortnight every:")
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/CaptureParserTests`
Expected: the build fails with `value of type 'ParsedCapture' has no member 'isPriority'`.

- [ ] **Step 3: Implement**

In the token loop of `parse`, add two checks before the `#` tag check:
- A token equal to `"!"` sets priority and is consumed.
- A token whose lowercase starts with `every:` is matched on its value after trimming trailing `.,;:!?)`. The values are `day` → `.daily`, `weekday`/`weekdays` → `.weekdays`, `week` → `.weekly` and `month` → `.monthly(day: nil)`. A match is consumed; anything else falls through to `kept`.

In `CaptureBar.save()`, add `entry.isPriority = parsed.isPriority` and `entry.setRepeat(parsed.repeatRule)` inside the `withAnimation` block, after `link(entry, parsed)`.

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass. Run both app builds and expect both to succeed.

- [ ] **Step 5: Commit**

`git commit -am "Capture: ! marks priority, every: sets repeat"`

---

### Task 3: Recurrence dates — `Recurrence.nextShowOn`

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/Recurrence.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/RecurrenceRuleTests.swift`

**Interfaces:**
- Consumes: `RepeatRule` (Task 1)
- Produces: `public enum Recurrence { public static func nextShowOn(rule: RepeatRule, after showOn: Date, closedOn: Date, calendar: Calendar = .current) -> Date }`. The result is always a start of day.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Recurrence dates")
struct RecurrenceRuleTests {
    func next(_ rule: RepeatRule, _ showOn: Date, closed: Date, calendar: Calendar = ist) -> Date {
        Recurrence.nextShowOn(rule: rule, after: showOn, closedOn: closed, calendar: calendar)
    }

    @Test func daily() { #expect(next(.daily, at(2026,10,19), closed: at(2026,10,19,18)) == at(2026,10,20)) }

    @Test("Closing late gives the next future date, not catch-up copies")
    func lateClose() {
        #expect(next(.daily, at(2026,10,19), closed: at(2026,10,22,9)) == at(2026,10,23))
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,11,4,9)) == at(2026,11,9))
    }

    @Test("Weekdays skip Saturday and Sunday")
    func weekdays() {
        #expect(next(.weekdays, at(2026,10,22), closed: at(2026,10,22,18)) == at(2026,10,23)) // Thu → Fri
        #expect(next(.weekdays, at(2026,10,23), closed: at(2026,10,23,18)) == at(2026,10,26)) // Fri → Mon
        #expect(next(.weekdays, at(2026,10,23), closed: at(2026,10,24,10)) == at(2026,10,26)) // closed Sat → Mon
    }

    @Test("Weekly keeps showOn's weekday even when closed mid-week")
    func weekly() {
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,10,19,18)) == at(2026,10,26))
        #expect(next(.weekly, at(2026,10,19), closed: at(2026,10,21,9)) == at(2026,10,26))
    }

    @Test("Monthly clamps to short months and returns to its anchor")
    func monthlyClamping() {
        let r = RepeatRule.monthly(day: 31)
        #expect(next(r, at(2027,1,31), closed: at(2027,1,31,18)) == at(2027,2,28))
        #expect(next(r, at(2027,2,28), closed: at(2027,2,28,18)) == at(2027,3,31))
        #expect(next(r, at(2027,3,31), closed: at(2027,3,31,18)) == at(2027,4,30))
        #expect(next(r, at(2028,1,31), closed: at(2028,1,31,18)) == at(2028,2,29))
    }

    @Test func monthlyLateCloseAndBareMonthly() {
        #expect(next(.monthly(day: 5), at(2026,10,5), closed: at(2026,11,10,9)) == at(2026,12,5))
        #expect(next(.monthly(day: nil), at(2026,10,19), closed: at(2026,10,19,9)) == at(2026,11,19))
    }

    @Test("Across a DST change the next date is still local midnight")   // Review Focus 1
    func dst() {
        var ny = Calendar(identifier: .gregorian); ny.timeZone = TimeZone(identifier: "America/New_York")!
        func nyAt(_ m: Int, _ d: Int, _ h: Int = 0) -> Date { ny.date(from: DateComponents(year: 2026, month: m, day: d, hour: h))! }
        // US clocks fall back on Sunday 2026-11-01.
        #expect(next(.daily, nyAt(10,31), closed: nyAt(10,31,20), calendar: ny) == nyAt(11,1))
        #expect(next(.daily, nyAt(11,1), closed: nyAt(11,1,20), calendar: ny) == nyAt(11,2))
        #expect(next(.weekly, nyAt(10,25), closed: nyAt(10,25,20), calendar: ny) == nyAt(11,1))
        #expect(next(.weekdays, nyAt(10,30), closed: nyAt(10,30,20), calendar: ny) == nyAt(11,2))
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/RecurrenceRuleTests`
Expected: `cannot find 'Recurrence' in scope`.

- [ ] **Step 3: Implement `nextShowOn`**

Step only with `calendar.date(byAdding: .day/.month …)`, never with seconds, so DST is safe:

```swift
let base = max(calendar.startOfDay(for: showOn), calendar.startOfDay(for: closedOn))
func dayAfter(_ d: Date) -> Date { calendar.date(byAdding: .day, value: 1, to: d)! }
var d = dayAfter(base)
switch rule {
case .daily: return d
case .weekdays:   // Mon–Fri by weekday number, not locale weekend
    while [1, 7].contains(calendar.component(.weekday, from: d)) { d = dayAfter(d) }
    return d
case .weekly:
    let target = calendar.component(.weekday, from: showOn)
    while calendar.component(.weekday, from: d) != target { d = dayAfter(d) }
    return d
case .monthly(let day):
    let anchor = day ?? calendar.component(.day, from: showOn)
    var month = calendar.dateInterval(of: .month, for: base)!.start
    while true {   // at most two passes
        let length = calendar.range(of: .day, in: .month, for: month)!.count
        let candidate = calendar.date(byAdding: .day, value: min(anchor, length) - 1, to: month)!
        if candidate > base { return candidate }
        month = calendar.date(byAdding: .month, value: 1, to: month)!
    }
}
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass.

- [ ] **Step 5: Commit**

`git add DayfoldCore && git commit -m "Recurrence: next showOn for daily, weekdays, weekly, monthly"`

---

### Task 4: Spawn next occurrence, close hook, dedupe, `Maintenance.tidy`

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/Recurrence.swift`, `Review.swift` (`import SwiftData`), `PeopleDirectory.swift` (`tidy`)
- Create: `DayfoldCore/Sources/DayfoldCore/Maintenance.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/RecurrenceSpawnTests.swift`
- Modify (close paths → context overload): `dayfold/Views/DayPageView.swift` (`apply`, `toggle`), `ReviewView.swift` (`decide`), `MenuBarCapture.swift`, `People/PersonView.swift` (`toggle`), `People/AllWaitingView.swift`. Add `@Environment(\.modelContext) private var context` to the files that lack it (ReviewView, MenuBarCapture, AllWaitingView).
- Modify: `dayfold/MyApp.swift` (the scenePhase handler calls `Maintenance.tidy(in:)`; update the comment to "Link legacy from: text, merge duplicate people, remove duplicate repeats.")

**Interfaces:**
- Consumes: `Recurrence.nextShowOn` (Task 3); `Entry.repeatRule`, `seriesID`, `ChecklistItem` (Task 1)
- Produces:
  - `@discardableResult public static func Recurrence.spawnNext(from entry: Entry, closedOn: Date, now: Date = Date(), in context: ModelContext, calendar: Calendar = .current) -> Entry?`
  - `public static func Recurrence.dedupe(in context: ModelContext) throws`
  - `public static func Review.apply(_ action: ReviewAction, to entry: Entry, now: Date = Date(), calendar: Calendar = .current, context: ModelContext)`: runs the existing apply, then on `.done` / `.drop` calls `spawnNext(from: entry, closedOn: now, now: now, in: context, calendar: calendar)`. The context-free overload stays and never spawns.
  - `public enum Maintenance { public static func tidy(in context: ModelContext) throws }`: backfill, then merge duplicates, then dedupe, then save. `PeopleDirectory.tidy(in:)` becomes `try Maintenance.tidy(in: context)`.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Repeating tasks") @MainActor
struct RecurrenceSpawnTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func repeating(_ text: String, _ rule: RepeatRule, showOn: Date) -> Entry {
        let e = Entry(text: text, createdAt: showOn, calendar: ist)
        context.insert(e); e.setRepeat(rule, calendar: ist)
        return e
    }
    private func series(_ e: Entry) throws -> [Entry] {
        try context.fetch(FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.showOn)])).filter { $0.seriesID == e.seriesID }
    }

    @Test("Spawn copies the task forward with an unchecked checklist and shifted due date")
    func spawnCopies() throws {
        let meera = Person(name: "Meera"); context.insert(meera)
        let e = repeating("Weekly report", .weekly, showOn: at(2026,10,19,9))
        e.scope = .personal; e.tags = ["reports"]; e.isPriority = true; e.from = "Meera"
        e.person = meera; e.link = .from; e.dueOn = at(2026,10,21)
        for (i, t) in ["collect metrics", "send"].enumerated() {
            let item = ChecklistItem(text: t, order: Double(i)); context.insert(item); item.entry = e; item.isDone = true
        }
        let now = at(2026,10,19,18)
        Review.apply(.done, to: e, now: now, calendar: ist, context: context)
        let all = try series(e)
        #expect(all.count == 2)
        let next = try #require(all.last)
        #expect(next.id != e.id && next.status == .open && next.closedAt == nil)
        #expect(next.text == "Weekly report" && next.kind == .task && next.scope == .personal)
        #expect(next.tags == ["reports"] && next.isPriority && next.repeatRaw == "weekly")
        #expect(next.seriesID == e.id && e.seriesID == e.id)
        #expect(next.person?.id == meera.id && next.link == .from && next.from == "Meera")
        #expect(next.showOn == at(2026,10,26) && next.dueOn == at(2026,10,28) && next.createdAt == now)
        let items = (next.checklist ?? []).sorted { $0.order < $1.order }
        #expect(items.map(\.text) == ["collect metrics", "send"] && items.allSatisfy { !$0.isDone })
        #expect(e.checklist?.count == 2)
    }

    @Test("A repeating delegated task comes back delegated with a fresh waiting clock")
    func delegatedRepeats() throws {
        let arjun = Person(name: "Arjun"); context.insert(arjun)
        let e = repeating("Status from Arjun", .daily, showOn: at(2026,10,19,9))
        Review.delegate(e, to: arjun, now: at(2026,10,19,9))
        e.nudgedAt = at(2026,10,19,15)
        let now = at(2026,10,19,18)
        Review.apply(.done, to: e, now: now, calendar: ist, context: context)   // "Got it"
        let next = try #require(try series(e).last)
        #expect(next.isWaiting && next.person?.id == arjun.id)
        #expect(next.delegatedAt == now && next.nudgedAt == nil && next.showOn == at(2026,10,20))
    }

    @Test("Notes and one-off tasks never spawn")
    func noSpawn() {
        let note = Entry(text: "n", kind: .note); context.insert(note); note.repeatRaw = "daily"
        let once = Entry(text: "t"); context.insert(once)
        #expect(Recurrence.spawnNext(from: note, closedOn: at(2026,10,19), in: context, calendar: ist) == nil)
        #expect(Recurrence.spawnNext(from: once, closedOn: at(2026,10,19), in: context, calendar: ist) == nil)
    }

    @Test("Drop spawns too; the context-free apply never spawns")
    func applyOverloads() throws {
        let a = repeating("a", .daily, showOn: at(2026,10,19))
        Review.apply(.drop, to: a, now: at(2026,10,19,18), calendar: ist, context: context)
        #expect(try series(a).count == 2)
        let b = repeating("b", .daily, showOn: at(2026,10,19))
        Review.apply(.done, to: b, now: at(2026,10,19,18), calendar: ist)
        #expect(try series(b).count == 1)
    }

    @Test("Done, undo, done again leaves exactly one next occurrence")   // Review Focus 2
    func doubleClose() throws {
        let e = repeating("Water plants", .daily, showOn: at(2026,10,19))
        Review.apply(.done, to: e, now: at(2026,10,19,18), calendar: ist, context: context)
        Review.reopen(e)
        #expect(try series(e).count == 2)          // reopening keeps the spawned one
        Review.apply(.done, to: e, now: at(2026,10,19,19), calendar: ist, context: context)
        #expect(try series(e).count == 2)
    }

    @Test("The series id is the first occurrence's id, so two devices agree")   // Review Focus 3
    func seriesIDIsDeterministic() throws {
        let e = Entry(text: "Legacy", createdAt: at(2026,10,19), calendar: ist)
        context.insert(e); e.repeatRaw = "daily"                 // set without setRepeat: seriesID nil
        let next = try #require(Recurrence.spawnNext(from: e, closedOn: at(2026,10,19,18), in: context, calendar: ist))
        #expect(e.seriesID == e.id && next.seriesID == e.id)
    }

    @Test("Dedupe removes open duplicates of one occurrence, keeping the oldest")   // Review Focus 3
    func dedupe() throws {
        let sid = UUID()
        func occ(_ created: Date, showOn: Date, status: EntryStatus = .open) -> Entry {
            let e = Entry(text: "Weekly report", createdAt: created, showOn: showOn, calendar: ist)
            context.insert(e); e.repeatRaw = "weekly"; e.seriesID = sid; e.status = status
            return e
        }
        let keep = occ(at(2026,10,19,18), showOn: at(2026,10,26))
        let dup = occ(at(2026,10,19,20), showOn: at(2026,10,26))
        let item = ChecklistItem(text: "x"); context.insert(item); item.entry = dup
        let closed = occ(at(2026,10,19,21), showOn: at(2026,10,26), status: .done)
        let earlier = occ(at(2026,10,12,18), showOn: at(2026,10,19))
        let ids = (keep: keep.id, closed: closed.id, earlier: earlier.id)
        try context.save()
        try Recurrence.dedupe(in: context); try context.save()
        let left = try context.fetch(FetchDescriptor<Entry>()).filter { $0.seriesID == sid }.map(\.id)
        #expect(Set(left) == [ids.keep, ids.closed, ids.earlier])
        #expect(try context.fetch(FetchDescriptor<ChecklistItem>()).isEmpty)
    }

    @Test("Maintenance.tidy links people and removes duplicate repeats; PeopleDirectory.tidy delegates")
    func tidy() throws {
        let legacy = Entry(text: "x", from: "priya"); context.insert(legacy)
        let sid = UUID()
        for h in [18, 20] {
            let e = Entry(text: "r", createdAt: at(2026,10,19,h), showOn: at(2026,10,20), calendar: ist)
            context.insert(e); e.seriesID = sid; e.repeatRaw = "daily"
        }
        try Maintenance.tidy(in: context)
        #expect(legacy.person?.name == "Priya")
        #expect(try context.fetch(FetchDescriptor<Entry>()).filter { $0.seriesID == sid }.count == 1)
        try PeopleDirectory.tidy(in: context)
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/RecurrenceSpawnTests`
Expected: `extra argument 'context' in call` / `cannot find 'Maintenance' in scope`.

- [ ] **Step 3: Implement `spawnNext`, the `apply` overload, `dedupe` and `Maintenance`**

`spawnNext`:
1. Return nil unless `entry.kind == .task` and `entry.repeatRule != nil`.
2. Set `entry.seriesID = entry.seriesID ?? entry.id`.
3. Fetch the series with `#Predicate<Entry> { $0.seriesID == sid }`, where `let sid: UUID? = entry.seriesID`. Return nil if any other entry in it is active with `showOn > entry.showOn`.
4. Insert the copy as the spec lists. Use `showOn = nextShowOn(rule:after:closedOn:calendar:)`. Shift `dueOn` by the whole-day offset `dateComponents([.day], from: startOfDay(showOn), to: startOfDay(dueOn))` added to the new `showOn`.
5. Set the person: copy `from` first. When `link == .to`, call `Review.delegate(next, to: person, now: now)`, which sets `delegatedAt` and clears `nudgedAt`. Otherwise set `person` and `linkRaw` directly.
6. Copy the checklist as new `ChecklistItem(text:order:createdAt: now)` with `isDone` false.

`dedupe`: fetch entries whose `seriesID != nil`, sorted by `createdAt`. Group the active ones by `(seriesID, showOn)` and delete all but the first in each group.

- [ ] **Step 4: Switch every app close path to the context overload**

Replace each `Review.apply(x, to: e)` that can close a task with `Review.apply(x, to: e, context: context)`. The sites are `DayPageView.apply` and `.toggle`, `ReviewView.decide`, `MenuBarCapture`, `PersonView.toggle` and `AllWaitingView`. Leave `DemoData` as it is.

- [ ] **Step 5: Run the tests and builds**

Run the full suite and expect it to pass. Run both app builds and expect both to succeed. Confirm `grep -rn "Review.apply(" dayfold/Views` shows `context:` on every match.

- [ ] **Step 6: Commit**

`git add DayfoldCore dayfold && git commit -m "Recurrence: spawn next on done/drop, dedupe, Maintenance.tidy"`

---

### Task 5: Tags — key, counts, editor parse

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/Tags.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/TagsTests.swift`

**Interfaces:**
- Consumes: `PeopleDirectory.normalize`
- Produces:
  - `public struct TagCount: Identifiable, Equatable, Sendable { public let tag: String; public let count: Int; public var id: String { Tags.key(tag) } }`
  - `public enum Tags`:
    - `static func key(_ tag: String) -> String`: strips leading `#`s and trailing `.,;:!?)`, then applies `PeopleDirectory.normalize`.
    - `static func all(_ entries: [Entry]) -> [TagCount]`: the display form is the cleaned spelling (`#` and punctuation stripped, case kept) from the newest `createdAt` entry. The count is the number of entries. Sorted by count descending, then key ascending.
    - `static func parse(_ text: String) -> [String]`

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Tags")
struct TagsTests {
    private func entry(_ tags: [String], _ hour: Int) -> Entry {
        Entry(text: "x", createdAt: at(2026,10,19,hour), tags: tags, calendar: ist)
    }

    @Test("Spelling variants are one tag")   // Review Focus 4
    func keyNormalizes() {
        let k = Tags.key("hiring")
        for v in ["#Hiring", "HIRING", "hiring,", "#hiring.", "híring"] { #expect(Tags.key(v) == k) }
        #expect(Tags.key("hiring-plan") != k)
    }

    @Test("Counted per entry, newest spelling shown, by count then name")
    func all() {
        let tags = Tags.all([
            entry(["hiring"], 9), entry(["Hiring", "roadmap"], 12), entry(["hiring,", "#hiring"], 8),
            entry(["roadmap"], 10), entry(["ops"], 11), entry(["admin"], 7),
        ])
        #expect(tags.map(\.tag) == ["Hiring", "roadmap", "admin", "ops"])
        #expect(tags.map(\.count) == [3, 2, 1, 1])
    }

    @Test func parseEditorField() {
        #expect(Tags.parse("#hiring, roadmap  #Hiring ,, q4") == ["hiring", "roadmap", "q4"])
        #expect(Tags.parse(" , ") == [])
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/TagsTests`
Expected: `cannot find 'Tags' in scope`.

- [ ] **Step 3: Implement `Tags.swift`**

`parse` splits on whitespace and commas, strips leading `#`, drops empty strings, and keeps the first spelling of each key.

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass.

- [ ] **Step 5: Commit**

`git add DayfoldCore && git commit -m "Tags: normalized keys, counts, editor parsing"`

---

### Task 6: Search — matching, ordering, day groups, completion token

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/Search.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/SearchTests.swift`

**Interfaces:**
- Consumes: `Tags.key` (Task 5), `PeopleDirectory.normalize`, `Entry.repeatRule`, `isPriority`, `checklist`, `isWaiting`
- Produces:
  - `public struct SearchDayGroup: Identifiable { public let day: Date; public let entries: [Entry]; public var id: Date { day } }`
  - `public enum Search`:
    - `static func matches(_ entry: Entry, query: String) -> Bool`
    - `static func results(_ entries: [Entry], query: String) -> [Entry]`
    - `static func dayGroups(_ results: [Entry], calendar: Calendar = .current) -> [SearchDayGroup]`
    - `static func completionToken(in query: String) -> (sigil: Character, partial: String)?`

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Search") @MainActor
struct SearchTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    /// a: starred hiring task from Meera · b: done café task · c: waiting on Arjun
    /// d: note · e: weekly task with checklist, from-text "Priya"
    private func fixtures() -> [Entry] {
        let meera = Person(name: "Meera"), arjun = Person(name: "Arjun")
        [meera, arjun].forEach(context.insert)
        let a = Entry(text: "Send Q4 hiring plan", createdAt: at(2026,10,19,9), tags: ["Hiring"], calendar: ist)
        let b = Entry(text: "Café budget review", createdAt: at(2026,10,20,10), calendar: ist)
        let c = Entry(text: "Q4 capacity numbers", createdAt: at(2026,10,18,9), calendar: ist)
        let d = Entry(text: "1:1 with Sam", kind: .note, createdAt: at(2026,10,20,12), calendar: ist)
        let e = Entry(text: "Weekly report", createdAt: at(2026,10,17,9), from: "Priya", calendar: ist)
        [a, b, c, d, e].forEach(context.insert)
        a.person = meera; a.link = .from; a.isPriority = true
        b.status = .done; b.closedAt = at(2026,10,20,11)
        Review.delegate(c, to: arjun, now: at(2026,10,18,9))
        e.repeatRaw = "weekly"
        let item = ChecklistItem(text: "Collect metrics"); context.insert(item); item.entry = e
        return [a, b, c, d, e]
    }
    private func texts(_ q: String, _ all: [Entry]) -> [String] { Search.results(all, query: q).map(\.text) }

    @Test func tokensAreANDedAndEmptyIsNothing() {
        let all = fixtures()
        #expect(texts("  ", all).isEmpty)
        #expect(texts("q4", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])
        #expect(texts("q4 hiring", all) == ["Send Q4 hiring plan"])
        #expect(texts("q4 #", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])   // bare sigil ignored
    }

    @Test func tagsAndPeople() {
        let all = fixtures()
        #expect(texts("#hiring", all) == ["Send Q4 hiring plan"])
        #expect(texts("#hir", all).isEmpty)                      // tags match exactly
        #expect(texts("@mee", all) == ["Send Q4 hiring plan"])
        #expect(texts("@arj", all) == ["Q4 capacity numbers"])
        #expect(texts("@priya", all) == ["Weekly report"])       // from text
        #expect(texts("@sam", all).isEmpty)                      // name in text only
    }

    @Test func stateFilters() {
        let all = fixtures()
        #expect(texts("is:open", all) == ["Send Q4 hiring plan", "Q4 capacity numbers", "Weekly report"])
        #expect(texts("is:done", all) == ["Café budget review"])
        #expect(texts("is:waiting", all) == ["Q4 capacity numbers"])
        #expect(texts("is:priority", all) == ["Send Q4 hiring plan"])
        #expect(texts("is:repeating", all) == ["Weekly report"])
        #expect(texts("is:note", all) == ["1:1 with Sam"])
        #expect(texts("is:open q4", all) == ["Send Q4 hiring plan", "Q4 capacity numbers"])
    }

    @Test func diacriticsAndChecklistText() {
        let all = fixtures()
        #expect(texts("cafe", all) == ["Café budget review"])
        #expect(texts("CAFÉ", all) == ["Café budget review"])
        #expect(texts("metrics", all) == ["Weekly report"])
    }

    @Test("Open tasks first, then newest first; groups by capture day, newest day first")
    func orderingAndGroups() {
        let all = fixtures()
        let r = Search.results(all, query: "a")
        #expect(r.map(\.text) == ["Send Q4 hiring plan", "Q4 capacity numbers", "Weekly report",
                                  "1:1 with Sam", "Café budget review"])
        let groups = Search.dayGroups(r, calendar: ist)
        #expect(groups.map(\.day) == [at(2026,10,20), at(2026,10,19), at(2026,10,18), at(2026,10,17)])
        #expect(groups[0].entries.map(\.text) == ["1:1 with Sam", "Café budget review"])
    }

    @Test func completionToken() {
        #expect(Search.completionToken(in: "q4 #hi")! == ("#", "hi"))
        #expect(Search.completionToken(in: "@")! == ("@", ""))
        #expect(Search.completionToken(in: "q4 #hiring ") == nil)
        #expect(Search.completionToken(in: "plain") == nil)
    }

    @Test("Searching 5,000 entries stays interactive")   // Review Focus 5
    func largeStore() {
        let big = (0..<5_000).map { i in
            Entry(text: "Entry \(i) about the quarterly plan", createdAt: Date(timeIntervalSince1970: Double(i)), tags: ["t\(i % 50)"])
        }
        var hits: [Entry] = []
        let elapsed = ContinuousClock().measure { hits = Search.results(big, query: "#t7 quarterly") }
        #expect(hits.count == 100)
        #expect(elapsed < .seconds(1))
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/SearchTests`
Expected: `cannot find 'Search' in scope`.

- [ ] **Step 3: Implement `Search.swift`**

`results` parses the query into a private `[Token]` once per call, not once per entry. Kinds of token:
- `#x` matches when some tag has `Tags.key == Tags.key(x)`.
- `@x` matches when `normalize(person name)` or `normalize(from)` has the prefix `normalize(x)`.
- `is:open`, `is:done`, `is:waiting`, `is:priority`, `is:repeating`, `is:note`:
  - `open` means a task with an active status.
  - `done` means status `.done`.
  - `repeating` means `repeatRule != nil`.
- Any other token, including an unknown `is:` value, is a substring of a per-entry haystack. The haystack is `normalize` of text, tags, person name, from and checklist texts joined with `" "`, built once per entry.
- A bare `#` or `@` is dropped. An empty token list returns `[]`.

Sort stably: open tasks first, then by `createdAt` descending. `dayGroups` groups by `startOfDay(createdAt)`, newest day first, and keeps the input order inside each day.

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass.

- [ ] **Step 5: Commit**

`git add DayfoldCore && git commit -m "Search: token matching, ordering, day groups"`

---

### Task 7: Checklist helpers

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/ChecklistItem.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/ChecklistTests.swift`

**Interfaces:**
- Produces:
  - `Entry.sortedChecklist: [ChecklistItem]`: sorted by `order`, then `createdAt`.
  - `Entry.checklistProgress: (done: Int, total: Int)?`: nil when the checklist is empty.
  - `public enum Checklist`:
    - `@discardableResult static func add(_ text: String, to entry: Entry, in context: ModelContext) -> ChecklistItem?`: trims; returns nil for blank text; `order = (last?.order ?? -1) + 1`.
    - `static func move(in entry: Entry, from source: IndexSet, to destination: Int)`: same arguments as `onMove`.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Checklist") @MainActor
struct ChecklistTests {
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func entry(_ items: [String]) -> Entry {
        let e = Entry(text: "Ship"); context.insert(e)
        items.forEach { Checklist.add($0, to: e, in: context) }
        return e
    }
    private func texts(_ e: Entry) -> [String] { e.sortedChecklist.map(\.text) }

    @Test("Add appends in order, trims, ignores blanks")
    func add() {
        let e = entry([])
        #expect(e.checklistProgress == nil)
        Checklist.add(" draft ", to: e, in: context); Checklist.add("review", to: e, in: context)
        #expect(Checklist.add("   ", to: e, in: context) == nil)
        #expect(texts(e) == ["draft", "review"] && e.sortedChecklist.map(\.order) == [0, 1])
    }

    @Test("Progress counts ticks; ticking everything doesn't close the task")
    func progress() {
        let e = entry(["a", "b"])
        e.sortedChecklist[0].isDone = true
        #expect(e.checklistProgress?.done == 1 && e.checklistProgress?.total == 2)
        e.sortedChecklist[1].isDone = true
        #expect(e.checklistProgress?.done == 2 && e.status == .open)
    }

    @Test("Moving one item rewrites only that item's order")
    func moveMidpoint() {
        let e = entry(["x", "y", "z"])
        Checklist.move(in: e, from: [2], to: 1)
        #expect(texts(e) == ["x", "z", "y"] && e.sortedChecklist.map(\.order) == [0, 0.5, 1])
        Checklist.move(in: e, from: [0], to: 3)
        #expect(texts(e) == ["z", "y", "x"] && e.sortedChecklist[2].order == 2)
        Checklist.move(in: e, from: [2], to: 0)
        #expect(texts(e) == ["x", "z", "y"] && e.sortedChecklist[0].order == -0.5)
    }

    @Test("Items appended on two devices with equal order stay stable and can be reordered")
    func tiedOrders() {
        let e = Entry(text: "Ship"); context.insert(e)
        for (t, o, s) in [("p", 0.0, 0.0), ("q", 1, 10), ("r", 1, 20)] {
            let i = ChecklistItem(text: t, order: o, createdAt: Date(timeIntervalSince1970: s))
            context.insert(i); i.entry = e
        }
        #expect(texts(e) == ["p", "q", "r"])
        Checklist.move(in: e, from: [0], to: 2)
        #expect(texts(e) == ["q", "p", "r"] && e.sortedChecklist.map(\.order) == [0, 1, 2])
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/ChecklistTests`
Expected: `cannot find 'Checklist' in scope`.

- [ ] **Step 3: Implement**

SwiftUI's `move(fromOffsets:toOffset:)` isn't available in DayfoldCore, so `move` does the reorder by hand:

```swift
var items = entry.sortedChecklist
let moving = source.map { items[$0] }
let dest = destination - source.filter { $0 < destination }.count
items = items.enumerated().filter { !source.contains($0.offset) }.map(\.element)
items.insert(contentsOf: moving, at: dest)
guard moving.count == 1, let i = items.firstIndex(where: { $0 === moving[0] }) else { return renumber(items) }
let prev = i > 0 ? items[i - 1].order : nil
let next = i + 1 < items.count ? items[i + 1].order : nil
switch (prev, next) {
case let (p?, n?) where p < n: moving[0].order = (p + n) / 2
case (nil, let n?): moving[0].order = n - 1
case (let p?, nil): moving[0].order = p + 1
case (nil, nil): break
default: renumber(items)          // tie from concurrent appends
}
// renumber: items.enumerated().forEach { $1.order = Double($0) }
```

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass.

- [ ] **Step 5: Commit**

`git add DayfoldCore && git commit -m "Checklist: add, progress, midpoint reorder"`

---

### Task 8: Priority rules — day-page split and Review queue

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/DayPage.swift`, `Review.swift` (`queue`)
- Test: `DayfoldCore/Tests/DayfoldCoreTests/PriorityRulesTests.swift`

**Interfaces:**
- Consumes: `DayPageItem.isPriority` (Task 1)
- Produces:
  - `public static func DayPage.prioritySplit<Item: DayPageItem>(_ items: [Item]) -> (priority: [Item], timeline: [Item])`: `priority` holds starred tasks with an active status; `timeline` holds everything else. Both keep input order.
  - `Review.queue`: same signature. Its order is starred pending, then other pending (both stable), then stale waiting.

- [ ] **Step 1: Write the failing tests**

```swift
@Suite("Priority rules")
struct PriorityRulesTests {
    private func t(_ h: Int, priority: Bool = false, status: EntryStatus = .open,
                   kind: EntryKind = .task, link: PersonLink? = nil) -> FakeItem {
        FakeItem(createdAt: at(2026,10,19,h), kind: kind, status: status,
                 closedAt: status.isActive ? nil : at(2026,10,19,h), showOn: at(2026,10,19),
                 link: link, delegatedAt: link == .to ? at(2026,10,12) : nil, isPriority: priority)
    }

    @Test("Starred open tasks go to Priority; the timeline keeps capture order without them")
    func split() {
        let s = DayPage.prioritySplit([t(8), t(9, priority: true), t(10, priority: true, status: .done),
                                       t(11, priority: true, kind: .note), t(12, priority: true, status: .inProgress),
                                       t(13, priority: true, link: .to)])
        #expect(s.priority.map(\.createdAt) == [9, 12, 13].map { at(2026,10,19,$0) })
        #expect(s.timeline.map(\.createdAt) == [8, 10, 11].map { at(2026,10,19,$0) })
    }

    @Test("Review queue: starred own tasks first (stable), then the rest, then stale waiting")
    func queue() {
        let items = [t(9), t(10, priority: true), t(11), t(12, priority: true), t(13, priority: true, link: .to)]
        let q = Review.queue(items, on: at(2026,10,19,20), nudgeAfter: 3, calendar: ist)
        #expect(q.map(\.createdAt) == [10, 12, 9, 11, 13].map { at(2026,10,19,$0) })
    }
}
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run: `… -only-testing:DayfoldCoreTests/PriorityRulesTests`
Expected: `type 'DayPage' has no member 'prioritySplit'`.

- [ ] **Step 3: Implement**

`prioritySplit` is one pass that partitions into two arrays. `queue` becomes `let own = pending(…); return own.filter(\.isPriority) + own.filter { !$0.isPriority } + staleWaiting(…)`. The existing `queueOrder` test must still pass.

- [ ] **Step 4: Run the tests and confirm they pass**

Run the full suite and expect it to pass.

- [ ] **Step 5: Commit**

`git add DayfoldCore && git commit -m "Priority: day-page split and starred-first Review queue"`

---

### Task 9: Row and Review-card badges, SearchRouter

**Files:**
- Create: `dayfold/Views/SearchRouter.swift`
- Modify: `dayfold/Views/EntryRow.swift` (`meta`), `dayfold/Views/ReviewView.swift` (`card`, bottom `pairLayout`)

**Interfaces:**
- Consumes: `Entry.isPriority`, `repeatRule` (with `.title` and `.summary`), `checklistProgress`, `tags`
- Produces: `@Observable final class SearchRouter { static let shared; var query: String = ""; private(set) var shown: Int = 0; func show(_ query: String) }`. `show` sets `query` and increments `shown`, and `RootView` (Task 12) switches to Search when `shown` changes. The `EntryRow` signature is unchanged: `EntryRow(entry:day:showScope:onToggle:onPerson:)`.

- [ ] **Step 1: Write `SearchRouter.swift`** as specified in Interfaces.

- [ ] **Step 2: Add the row meta items**

Add these to `EntryRow.meta`, in this order, after the scope icon:
- When `isPriority`: `Image(systemName: "star.fill")`, `.foregroundStyle(.tint)`, accessibility label "Priority".
- When `repeatRule` is set: `Image(systemName: "repeat")`, accessibility label `rule.summary`.

Add these after the due date:
- Checklist progress: `Text("\(Image(systemName: "checklist")) \(p.done)/\(p.total)")`, accessibility label "\(p.done) of \(p.total) checklist items done".
- The first two tags as plain `.buttonStyle(.plain)` buttons labelled `"#\(tag)"`. Each runs `SearchRouter.shared.show("#\(tag)")`, with hint "Searches this tag".
- When there are more than two tags, `Text("+\(tags.count - 2)")`.

The existing accessibility-size `VStackLayout` fallback already wraps these items.

- [ ] **Step 3: Add the Review card badges**

In `ReviewView.card`'s bottom `pairLayout`, add:
- `Label("Priority", systemImage: "star.fill")` when starred.
- `Label(rule.title, systemImage: "repeat")` when repeating.
- `Label("\(p.done)/\(p.total)", systemImage: "checklist")` when the checklist is non-empty.

Add no new actions.

- [ ] **Step 4: Build**

Run both app builds and expect `** BUILD SUCCEEDED **` ×2.

- [ ] **Step 5: Commit**

`git add dayfold && git commit -m "Rows and Review cards show priority, repeat, checklist, tags"`

---

### Task 10: Entry editor — own file, Priority / Repeat / Tags / Checklist

**Files:**
- Create: `dayfold/Views/EntryEditor.swift` (move `private struct EntryEditor` out of `DayPageView.swift` as internal `struct EntryEditor`; remove it from `DayPageView.swift`)

**Interfaces:**
- Consumes: `Entry.setRepeat`, `RepeatRule.choice` (Task 1); `Tags.parse` (Task 5); `Checklist.add`, `Checklist.move`, `Entry.sortedChecklist` (Task 7)
- Produces: `EntryEditor(entry: Entry)`, which Task 12 presents from Search.

- [ ] **Step 1: Move the editor**

Move it unchanged, then build both targets and confirm they still succeed.

- [ ] **Step 2: Add the sections after the due-date section**

The editor needs `@Environment(\.modelContext)`. Priority, Repeat and Checklist appear only when `entry.kind == .task`; Tags appear always.
- **Priority section:**
  - `Toggle("Priority", isOn: $entry.isPriority)`.
  - `Picker("Repeat", selection:)`. The binding's get is `entry.repeatRule?.choice` and its set is `entry.setRepeat($0)`. The options are tagged `RepeatRule?`: "Never" (`nil`), "Daily", "Weekdays", "Weekly", "Monthly" (`.monthly(day: nil)`).
- **"Tags" section:** `TextField("Tags", text: $tagsText, prompt: Text("hiring, roadmap"))`. `@State tagsText` starts as `entry.tags.joined(separator: " ")`; `.onChange` writes `entry.tags = Tags.parse(tagsText)`.
- **"Checklist" section:**
  - `ForEach(entry.sortedChecklist)` row: a 44×44 tick button (`checkmark.circle.fill` or `circle`) that toggles `item.isDone`, with accessibility label "Mark done" or "Mark not done". Next to it, `Text(item.text)` struck through when done.
  - `.onDelete` deletes the items at the offsets via `context.delete`.
  - `.onMove { Checklist.move(in: entry, from: $0, to: $1) }`.
  - Last row: `TextField("Add item", text: $newItem)` with `.onSubmit { Checklist.add(newItem, to: entry, in: context); newItem = "" }`. It keeps focus so several items can be added in a row.
- Raise the sheet's `minHeight` to 520.

- [ ] **Step 3: Build and check by hand**

Run both builds. Then launch the Mac Debug build with `-demo`, open Edit… on a task, and check four things: adding three items, ticking one, reordering by drag (long-press drag on iOS), and choosing Monthly. Monthly must store `monthly:<showOn day>`; check via the row's ↻ and the picker reopening as Monthly.

- [ ] **Step 4: Commit**

`git add dayfold && git commit -m "Entry editor: priority, repeat, tags, checklist"`

---

### Task 11: Day page — Priority section, Star / Stop repeating

**Files:**
- Modify: `dayfold/Views/DayPageView.swift`

**Interfaces:**
- Consumes: `DayPage.prioritySplit` (Task 8); `Entry.setRepeat(nil)` (Task 1)

- [ ] **Step 1: Move the existing row into a function**

Move the existing `EntryRow` and all its modifiers (insets, swipes, context menu) into `private func row(_ entry: Entry) -> some View`.

- [ ] **Step 2: Lay out the Priority section**

The list keeps its header row first. When `split.priority` is non-empty, add `Section { ForEach(split.priority, content: row) } header: { Text("Priority") }`, styled like PersonView's section headers: `.caption.weight(.semibold)`, uppercase, secondary. Then `ForEach(split.timeline, content: row)`, where `split = DayPage.prioritySplit(items)`. Leave the header progress and the empty state reading `items`.

- [ ] **Step 3: Add the actions** (only for active tasks when `!isPast`)
- Leading swipe, after Done: `Button { star(entry) } label: { Label(entry.isPriority ? "Unstar" : "Star", systemImage: entry.isPriority ? "star.slash" : "star") }.tint(.accentColor)`.
- Context menu, after Drop: the same Star/Unstar button. Then, if `entry.repeatRule != nil`: `Button("Stop repeating", systemImage: "stop.circle") { entry.setRepeat(nil) }`.
- `star` toggles `isPriority` inside `withAnimation(.snappy)` and is paired with `.sensoryFeedback(.selection, trigger:)` on the starred state.

- [ ] **Step 4: Build**

Run both app builds and expect both to succeed.

- [ ] **Step 5: Commit**

`git commit -am "Day page: Priority section, Star and Stop repeating"`

---

### Task 12: Search screen, Search tab / sidebar, Tags sidebar, `-search`

**Files:**
- Create: `dayfold/Views/SearchView.swift`
- Modify: `dayfold/Views/RootView.swift`

**Interfaces:**
- Consumes: `Search.results`, `dayGroups`, `completionToken` (Task 6); `Tags.all`, `TagCount` (Task 5); `SearchRouter.shared` (Task 9); `EntryEditor(entry:)` (Task 10); `Review.apply(_:to:context:)` (Task 4); `PeopleDirectory.completions`
- Produces: `SearchView()`, which is placed inside a `NavigationStack` by `RootView`.

- [ ] **Step 1: Write `SearchView`**

State: `@Query(sort: \Entry.createdAt)` entries, `@Query(sort: \Person.name)` people, `@Bindable var router = SearchRouter.shared`, `@State editing: Entry?`, `@State openedPerson: Person?`.

`List` on `Color.paper`, `.scrollContentBackground(.hidden)`, `.navigationTitle("Search")`, `.searchable(text: $router.query, prompt: "Search everything")`. The body has three states:
- **Browse (trimmed query empty).**
  - A row of chips "Open", "Priority", "Repeating" and "Waiting". They set `router.query` to `is:open`, `is:priority`, `is:repeating` and `is:waiting`.
  - Then a "Tags" caption and a wrapping cloud of `TagCount` chips, labelled `"#\(tag)  \(count)"`, that set `router.query = "#\(tag)"`.
  - Chips are capsules on `Color.card` with a separator stroke and a 44pt min height, like CaptureBar's suggestion chips.
  - Add a private `FlowLayout: Layout` (8pt spacing) in this file.
- **No results.** `ContentUnavailableView("Nothing matches", systemImage: "magnifyingglass", description: Text("Nothing matches “\(query)”."))`.
- **Results.**
  - `ForEach(Search.dayGroups(results)) { Section { rows } header: { Text(group.day, format: .dateTime.weekday(.wide).day().month(.wide)).font(.system(.headline, design: .serif)) } }`.
  - Each row is `EntryRow(entry:day: today) { toggle }` with `onPerson: { openedPerson = $0 }`. `toggle` is done ↔ reopen through `Review.apply(.done, to:, context:)`.
  - Each row also gets `.contentShape(Rectangle()).onTapGesture { editing = entry }`.
- **Sheets and navigation.** `.sheet(item: $editing) { EntryEditor(entry: $0) }` and `.navigationDestination(item: $openedPerson) { PersonView(person: $0) }`.
- **Completions.** `.searchSuggestions`: when `Search.completionToken(in: router.query)` returns `#`, show up to 5 tag names whose key has the prefix `Tags.key(partial)`; when it returns `@`, show `PeopleDirectory.completions(for:in:)` names. Each suggestion is a `Button` that replaces the trailing token with `#tag ` or `@First_Last ` (spaces become underscores).
- Results are computed in `body`. Add `// ponytail: recomputed per keystroke; 5k entries < 1s (SearchTests.largeStore). Debounce if stores grow past that.`

- [ ] **Step 2: Wire up `RootView`**

On iOS:
- Third tab: `NavigationStack { SearchView() }.tabItem { Label("Search", systemImage: "magnifyingglass") }.tag(2)`.
- `.onChange(of: SearchRouter.shared.shown) { tab = 2 }`.
- DEBUG: `-search` starts on tab 2. When the next argument exists and doesn't start with `-`, it becomes `SearchRouter.shared.query`.

On Mac:
- `SidebarItem` gains `.search` and `.tag(String)`, and `RootView` gets `@Query(sort: \Entry.createdAt) entries`.
- `Label("Search", systemImage: "magnifyingglass")` goes after People.
- A `Section("Tags")` lists `Tags.all(entries).prefix(8)` as `Label("#\(t.tag)", systemImage: "number").badge(t.count).tag(SidebarItem.tag(t.tag))`.
- Detail: `.search` and `.tag` both show `NavigationStack { SearchView() }`.
- `.onChange(of: selection)`: when the selection is `.tag(t)`, set `SearchRouter.shared.query = "#\(t)"`.
- `.onChange(of: SearchRouter.shared.shown) { selection = .search }`.
- DEBUG: `-search` selects `.search`, with the same optional query as on iOS.

- [ ] **Step 3: Build**

Run both app builds and expect both to succeed.

- [ ] **Step 4: Commit**

`git add dayfold && git commit -m "Search screen, Search tab and sidebar, Tags sidebar, -search flag"`

---

### Task 13: Demo data, screenshot pass, docs

**Files:**
- Modify: `dayfold/DemoData.swift`, `CLAUDE.md`, `docs/spec.md`

- [ ] **Step 1: Add demo content** in `DemoData.container()`, before `return`:
- `samples[0]` (Q4 hiring plan): `isPriority = true`, tags `["hiring"]`.
- `samples[3]` (migration checklist): `isPriority = true`, tags `["release"]`, and `Checklist.add` "Run dry-run", "Sign rollback plan" and "Notify on-call", with the first ticked.
- `samples[5]` (interview feedback): tags `["hiring"]`.
- `samples[4]` (1:1 note): tags `["1on1"]`.
- A new "Weekly status report" task, created 7 days ago at 09:00 with tags `["reports"]` and `setRepeat(.weekly)`. Close it with `Review.apply(.done, to:, now: at(0, 9, 30), context: ctx)` so that the next occurrence exists.
- A new personal task "Water the plants", created 0 days ago at 08:00, with `setRepeat(.daily)`.

- [ ] **Step 2: Build and take screenshots** on the iPhone 16 Pro simulator

```bash
xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -derivedDataPath build/sim build CODE_SIGNING_ALLOWED=NO
xcrun simctl boot "iPhone 16 Pro"; xcrun simctl install booted build/sim/Build/Products/Debug-iphonesimulator/dayfold.app
xcrun simctl launch --terminate-running-process booted com.rockykusuma.dayfold.app -demo            # then: xcrun simctl io booted screenshot <file>
```

Capture these screens:
- The day page in light and dark mode (`xcrun simctl ui booted appearance dark`).
- `-demo -search` (browse chips and tag cloud).
- `-demo -search '#hiring'` (results grouped by day).
- `-demo -review` (card shows ★, ↻ and 1/3).
- The day page and search results at `xcrun simctl ui booted content_size accessibility-extra-extra-extra-large`.
- iPhone SE (3rd generation): the Search browse screen.

Check each screen against the spec's Screens section:
- The Priority caption sits above the timeline, and starred items are not repeated below.
- ★ is ink-coloured, ↻ is present, and progress reads `1/3`.
- Tags show at most two plus `+N`.
- Nothing truncates at accessibility sizes, targets are 44pt, and both themes are readable.

Fix anything that's off in the view that owns it, then take the screenshot again. On the Mac, run `open` on the Debug build `--args -demo` and check the sidebar: Search, plus a Tags section with counts. Take a window screenshot only (`screencapture -l <windowid>`), never a full-screen capture.

- [ ] **Step 3: Run full verification**

Run `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS` and expect all tests to pass. Run both app builds in Debug **and** with `-configuration Release`; expect four `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Update the docs**

In `CLAUDE.md`:
- Layout: add `SearchView.swift`, `SearchRouter.swift`, `EntryEditor.swift` and the new DayfoldCore files (`Recurrence`, `Maintenance`, `Search`, `Tags`, `ChecklistItem`).
- Debug flags: add `-search [query]` (Search tab/sidebar, optional query).
- State: add a "Find & organise done" line.
- The CloudKit reminder now reads "deploy schema (Person, ChecklistItem + new Entry fields) to production".

Append to the `docs/spec.md` decisions log:

```markdown
- 2026-10-19 Find & organise: search (AND tokens, #tag, @person, is: filters), visible tags,
  checklists (ChecklistItem model), repeating tasks (daily / weekdays / weekly / monthly:<day>;
  next occurrence spawned on done/drop, never catch-up copies; dedupe on foreground),
  single-level priority (Priority section above the timeline, starred first in Review).
  Spec: docs/superpowers/specs/2026-10-19-find-organise-design.md
- Before the first TestFlight build: deploy the CloudKit schema (ChecklistItem + Entry
  isPriority / repeatRaw / seriesID / checklist) to production in the CloudKit Console.
```

- [ ] **Step 5: Commit**

`git add dayfold CLAUDE.md docs/spec.md && git commit -m "Find & organise: demo data, docs"`
