# People & Delegation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add people (roles, teams), "waiting on" delegation, 1:1 notes and Review nudges to Dayfold on iPhone and Mac.

**Architecture:** A new `Person` SwiftData model in `DayfoldCore`, linked one-to-many to `Entry` via an optional relationship plus a `linkRaw` (`from` / `to` / `about`). All rules (name matching, merge, backfill, waiting/stale logic) are pure functions in `DayfoldCore` with Swift Testing tests. The app adds a people picker, person/people screens, Review waiting cards, and switches the root to tabs (iPhone) / sidebar (Mac).

**Tech Stack:** Swift 5 language mode, SwiftUI (iOS 17 / macOS 14), SwiftData with CloudKit private database, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-10-18-people-delegation-design.md`

## Global Constraints

- Deployment targets: iOS 17, macOS 14. Prefer APIs available on both.
- CloudKit: every stored property has a default or is optional; no `@Attribute(.unique)`; enums stored as raw strings; relationships optional with an inverse.
- Logic lives in `DayfoldCore` with tests; views stay thin.
- Carry-forward is a query (`DayPage.contains`), never a copy.
- Don't run `swift test`; run tests with `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`.
- App build check (both must pass after every app task):
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO`
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
- Style: ink accent (`.tint` / `Color.accentColor`), `Color.paper` backgrounds, `Color.card` surfaces, serif (`design: .serif`) for names/titles, `.snappy` animations, 44pt tap targets, `@ScaledMetric` for icon frames.
- Nudge threshold: `@AppStorage("review.nudgeAfter")`, default 3, range 1–14.
- Commit messages end with:
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` and `Claude-Session: https://claude.ai/code/session_016KuWvS3f2pThajg7yChjq9`

## Review Focus

1. **Trailing punctuation on names** — `to:arjun,` or `from:priya.` must resolve to "arjun"/"priya", not create "Arjun,". Test in Task 5.
2. **Delegating a task someone asked for** — Priya asked, R delegates to Arjun: the "asked by Priya" fact must survive as `from` text. Test in Task 3.
3. **Orphaned link from sync** — an entry with `linkRaw == "to"` whose person was deleted on another device must not count as waiting. Test in Task 1.
4. **Diacritics/case in names** — typing `jose` must match "José". Test in Task 2.
5. **Stale boundary** — delegated Monday 18:00, Review Thursday 09:00 with threshold 3 → stale (whole calendar days, inclusive). Test in Task 3.

## Simplifications vs spec (flagged for review)

- Review: instead of a separate tappable divider card, waiting cards show a "Waiting on others · N" label above the card. Same information, one fewer tap.
- Review "Message…": the share sheet cannot report whether a message was sent, so it does not auto-apply "Nudged today"; R taps **Nudged today** after sending.
- Mac: two-column split view (sidebar + detail); People detail is a `NavigationStack` that pushes the person page, instead of a fixed third column.
- No manual "+ add person" button: people are created from capture, the Delegate picker ("Add '…'"), or the person-page merge flow.

## File map

| File | Responsibility |
|---|---|
| `DayfoldCore/Sources/DayfoldCore/Person.swift` (new) | `Person` model, `PersonRole`, `PersonLink` |
| `DayfoldCore/Sources/DayfoldCore/Entry.swift` (modify) | `person`, `linkRaw`, `link`, `delegatedAt`, `nudgedAt` |
| `DayfoldCore/Sources/DayfoldCore/DayPage.swift` (modify) | `DayPageItem` gains link fields + `isWaiting` |
| `DayfoldCore/Sources/DayfoldCore/PeopleDirectory.swift` (new) | normalize / match / findOrCreate / merge / backfill / delete / completions / tidy |
| `DayfoldCore/Sources/DayfoldCore/Review.swift` (modify) | waiting excluded, `waitingDays`, `staleWaiting`, `queue`, `.nudged`, `delegate` |
| `DayfoldCore/Sources/DayfoldCore/PersonPage.swift` (new) | owed / waiting / notes / allWaiting |
| `DayfoldCore/Sources/DayfoldCore/CaptureParser.swift` (modify) | `to:` + name cleanup |
| `DayfoldCore/Tests/DayfoldCoreTests/*` | new suites per task; `FakeItem` gains link fields |
| `dayfold/MyApp.swift`, `dayfold/DemoData.swift` | schema, tidy on launch/foreground, root view, demo people |
| `dayfold/Views/CaptureBar.swift` | link on save, autocomplete strip, person-page linking |
| `dayfold/Views/EntryRow.swift` | ⇢ waiting mark, person name (tappable) |
| `dayfold/Views/People/PeoplePicker.swift` (new) | search/pick/add person sheet |
| `dayfold/Views/DayPageView.swift` | Delegate action, review queue, person navigation |
| `dayfold/Views/ReviewView.swift` | waiting cards, Delegate in Push menu, tally |
| `dayfold/Views/SettingsView.swift` | Nudge after stepper |
| `dayfold/Views/People/PeopleListView.swift`, `PersonView.swift`, `PersonEditor.swift`, `AllWaitingView.swift` (new) | people screens |
| `dayfold/Views/RootView.swift` (new) | tabs (iPhone) / sidebar (Mac) |

---

### Task 1: Person model and Entry link fields

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/Person.swift`
- Modify: `DayfoldCore/Sources/DayfoldCore/Entry.swift` (add fields after `tags`, add `link` accessor)
- Modify: `DayfoldCore/Sources/DayfoldCore/DayPage.swift` (protocol)
- Modify: `DayfoldCore/Tests/DayfoldCoreTests/DayPageTests.swift` (`FakeItem`)
- Test: `DayfoldCore/Tests/DayfoldCoreTests/PeopleModelTests.swift`

**Interfaces:**
- Produces: `Person` (`id`, `name`, `roleRaw`, `role: PersonRole`, `team: String?`, `createdAt`, `isSorted: Bool`, `entries: [Entry]?`, `init(name:role:team:createdAt:)`); `PersonRole { report, manager, peer, other }`; `PersonLink { from, to, about }`; `Entry.person: Person?`, `Entry.linkRaw: String?`, `Entry.link: PersonLink?` (nil when `person == nil`), `Entry.delegatedAt: Date?`, `Entry.nudgedAt: Date?`; `DayPageItem.link/delegatedAt/nudgedAt`; `DayPageItem.isWaiting: Bool`.

- [ ] **Step 1: Write the failing test** — `PeopleModelTests.swift`

```swift
import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@MainActor
func makeContainer() -> ModelContainer {
    try! ModelContainer(for: Entry.self, Person.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}

@Suite("People model") @MainActor
struct PeopleModelTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test func personDefaults() {
        let p = Person(name: "Priya")
        #expect(p.role == .other)
        #expect(p.team == nil)
        #expect(p.isSorted == false)
    }

    @Test("Linking an entry shows it on the person and makes it waiting")
    func linkRoundTrip() throws {
        let p = Person(name: "Priya")
        let e = Entry(text: "Q4 numbers")
        context.insert(p); context.insert(e)
        e.person = p
        e.link = .to
        try context.save()
        #expect(p.entries?.contains { $0.id == e.id } == true)
        #expect(e.isWaiting)
    }

    @Test("A 'to' link with no person is not waiting (deleted elsewhere)")
    func orphanLinkIsNotWaiting() {
        let e = Entry(text: "x")
        e.linkRaw = PersonLink.to.rawValue
        #expect(e.link == nil)
        #expect(e.isWaiting == false)
    }
}
```

Note: `makeContainer()` is reused by later suites; keep it at file scope here.

- [ ] **Step 2: Run to verify it fails**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/PeopleModelTests`
Expected: build failure — `cannot find 'Person' in scope`.

- [ ] **Step 3: Implement** — `Person.swift`

```swift
import Foundation
import SwiftData

public enum PersonRole: String, Codable, CaseIterable, Sendable {
    case report, manager, peer, other
}

/// How an entry relates to its person.
public enum PersonLink: String, Codable, CaseIterable, Sendable {
    /// They asked me — shows under "You owe".
    case from
    /// I'm waiting on them — delegated work.
    case to
    /// A 1:1 note about them.
    case about
}

/// Someone R works with. Created automatically from `from:` / `to:` in capture.
/// CloudKit rules: defaults everywhere, no unique attributes, optional relationship with inverse.
@Model
public final class Person {
    public var id: UUID = UUID()
    public var name: String = ""
    public var roleRaw: String = PersonRole.other.rawValue
    public var team: String?
    public var createdAt: Date = Date()
    /// False until R saves the Edit sheet; drives the "Unsorted" list.
    public var isSorted: Bool = false
    @Relationship(deleteRule: .nullify, inverse: \Entry.person)
    public var entries: [Entry]?

    public init(name: String, role: PersonRole = .other, team: String? = nil, createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.roleRaw = role.rawValue
        self.team = team
        self.createdAt = createdAt
    }

    public var role: PersonRole {
        get { PersonRole(rawValue: roleRaw) ?? .other }
        set { roleRaw = newValue.rawValue }
    }
}
```

In `Entry.swift`, after `public var tags: [String] = []` add:

```swift
    /// Who this entry is about / for / from. See `link`.
    public var person: Person?
    public var linkRaw: String?
    /// When this became "waiting on" (`link == .to`).
    public var delegatedAt: Date?
    /// Last time R followed up on a waiting item.
    public var nudgedAt: Date?
```

and after the `status` accessor add:

```swift
    /// Nil when no person is attached, so a link orphaned by a sync-side delete never counts.
    public var link: PersonLink? {
        get { person == nil ? nil : linkRaw.flatMap(PersonLink.init(rawValue:)) }
        set { linkRaw = newValue?.rawValue }
    }
```

In `DayPage.swift`, extend the protocol and add `isWaiting`:

```swift
public protocol DayPageItem {
    var createdAt: Date { get }
    var kind: EntryKind { get }
    var status: EntryStatus { get }
    var closedAt: Date? { get }
    var showOn: Date { get }
    var link: PersonLink? { get }
    var delegatedAt: Date? { get }
    var nudgedAt: Date? { get }
}

public extension DayPageItem {
    /// An open task R handed to someone else.
    var isWaiting: Bool { kind == .task && link == .to && status.isActive }
}
```

In `DayPageTests.swift`, extend `FakeItem`:

```swift
struct FakeItem: DayPageItem {
    var createdAt: Date
    var kind: EntryKind = .task
    var status: EntryStatus = .open
    var closedAt: Date? = nil
    var showOn: Date
    var link: PersonLink? = nil
    var delegatedAt: Date? = nil
    var nudgedAt: Date? = nil
}
```

- [ ] **Step 4: Run all core tests**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: all suites pass (14 existing + 3 new).

- [ ] **Step 5: Commit**

```bash
git add DayfoldCore
git commit -m "Core: Person model and entry person links"
```

---

### Task 2: PeopleDirectory — matching, merge, backfill, delete, completions

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/PeopleDirectory.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/PeopleDirectoryTests.swift`

**Interfaces:**
- Consumes: `Person`, `Entry.person/link/from` (Task 1).
- Produces:
  - `PeopleDirectory.normalize(_ name: String) -> String`
  - `PeopleDirectory.displayName(_ typed: String) -> String`
  - `PeopleDirectory.match(_ typed: String, in names: [String]) -> Int?`
  - `PeopleDirectory.findOrCreate(_ typed: String, in context: ModelContext) throws -> Person`
  - `PeopleDirectory.merge(_ duplicate: Person, into keeper: Person, in context: ModelContext)`
  - `PeopleDirectory.mergeDuplicates(in context: ModelContext) throws`
  - `PeopleDirectory.backfillFromText(in context: ModelContext) throws`
  - `PeopleDirectory.delete(_ person: Person, in context: ModelContext)`
  - `PeopleDirectory.tidy(in context: ModelContext) throws` (backfill → merge → save)
  - `PeopleDirectory.completionToken(in text: String) -> (keyword: String, partial: String)?`
  - `PeopleDirectory.completions(for partial: String, in names: [String], limit: Int = 5) -> [Int]`

- [ ] **Step 1: Write the failing tests** — `PeopleDirectoryTests.swift`

```swift
import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("People directory — names")
struct PeopleNameTests {
    @Test func normalizeIgnoresCaseSpacesUnderscoresAndDiacritics() {
        #expect(PeopleDirectory.normalize(" Priya ") == PeopleDirectory.normalize("PRIYA"))
        #expect(PeopleDirectory.normalize("priya_sharma") == PeopleDirectory.normalize("Priya  Sharma"))
        #expect(PeopleDirectory.normalize("jose") == PeopleDirectory.normalize("José"))
    }

    @Test func displayNameCapitalisesWordsAndKeepsTheRest() {
        #expect(PeopleDirectory.displayName("priya_sharma") == "Priya Sharma")
        #expect(PeopleDirectory.displayName("mcDonald") == "McDonald")
    }

    @Test func matchPrefersExactThenUniquePrefix() {
        let names = ["Priya Sharma", "Priya Nair", "Arjun", "José"]
        #expect(PeopleDirectory.match("arjun", in: names) == 2)
        #expect(PeopleDirectory.match("arj", in: names) == 2)
        #expect(PeopleDirectory.match("priya", in: names) == nil)          // ambiguous
        #expect(PeopleDirectory.match("priya_n", in: names) == 1)
        #expect(PeopleDirectory.match("jose", in: names) == 3)
        #expect(PeopleDirectory.match("", in: names) == nil)
    }

    @Test func completionTokenOnlyForTrailingFromOrTo() {
        #expect(PeopleDirectory.completionToken(in: "Ask for numbers to:ar")! == ("to:", "ar"))
        #expect(PeopleDirectory.completionToken(in: "x from:")! == ("from:", ""))
        #expect(PeopleDirectory.completionToken(in: "to:arjun done") == nil)
        #expect(PeopleDirectory.completionToken(in: "plain text") == nil)
    }

    @Test func completionsArePrefixMatchesUpToLimit() {
        let names = ["Priya Sharma", "Priya Nair", "Arjun", "Pat"]
        #expect(PeopleDirectory.completions(for: "pri", in: names) == [0, 1])
        #expect(PeopleDirectory.completions(for: "", in: names, limit: 2) == [0, 1])
    }
}

@Suite("People directory — store") @MainActor
struct PeopleStoreTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func people() throws -> [Person] {
        try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    @Test func findOrCreateReusesExisting() throws {
        let a = try PeopleDirectory.findOrCreate("priya", in: context)
        try context.save()
        let b = try PeopleDirectory.findOrCreate("Priya", in: context)
        #expect(a.id == b.id)
        #expect(try people().count == 1)
        #expect(a.name == "Priya")
    }

    @Test("Merge keeps the oldest, moves entries, fills missing details, and is idempotent")
    func mergeDuplicates() throws {
        let old = Person(name: "Priya", createdAt: Date(timeIntervalSince1970: 0))
        let dup = Person(name: "priya", role: .report, team: "Platform", createdAt: Date(timeIntervalSince1970: 100))
        let e = Entry(text: "x")
        [old, dup].forEach(context.insert); context.insert(e)
        e.person = dup; e.link = .from
        try context.save()

        try PeopleDirectory.mergeDuplicates(in: context)
        try context.save()
        let left = try people()
        #expect(left.count == 1)
        #expect(left[0].id == old.id)
        #expect(left[0].role == .report && left[0].team == "Platform")
        #expect(e.person?.id == old.id && e.link == .from)

        try PeopleDirectory.mergeDuplicates(in: context)
        #expect(try people().count == 1)
    }

    @Test("Merge keeps the keeper's own role and team when it has them")
    func mergeKeepsKeeperDetails() throws {
        let keeper = Person(name: "Sam", role: .peer, team: "Sync", createdAt: Date(timeIntervalSince1970: 0))
        let dup = Person(name: "sam", role: .report, team: "Platform", createdAt: Date(timeIntervalSince1970: 1))
        [keeper, dup].forEach(context.insert)
        PeopleDirectory.merge(dup, into: keeper, in: context)
        #expect(keeper.role == .peer && keeper.team == "Sync")
    }

    @Test("Backfill links legacy from: text once and ignores blanks")
    func backfill() throws {
        let a = Entry(text: "a", from: "priya")
        let b = Entry(text: "b", from: "Priya")
        let c = Entry(text: "c", from: "  ")
        [a, b, c].forEach(context.insert)
        try PeopleDirectory.backfillFromText(in: context)
        try PeopleDirectory.backfillFromText(in: context)
        try context.save()
        #expect(try people().count == 1)
        #expect(a.link == .from && b.person?.id == a.person?.id)
        #expect(c.person == nil)
    }

    @Test("Delete keeps entries, unlinks them, and backfill doesn't resurrect the person")
    func deleteUnlinks() throws {
        let p = Person(name: "Arjun")
        let waiting = Entry(text: "sync doc", from: "arjun")
        context.insert(p); context.insert(waiting)
        waiting.person = p; waiting.link = .to
        try context.save()

        PeopleDirectory.delete(p, in: context)
        try context.save()
        #expect(try people().isEmpty)
        #expect(waiting.person == nil && waiting.linkRaw == nil && waiting.isWaiting == false)
        try PeopleDirectory.backfillFromText(in: context)
        #expect(try people().isEmpty)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/PeopleNameTests -only-testing:DayfoldCoreTests/PeopleStoreTests`
Expected: build failure — `cannot find 'PeopleDirectory' in scope`.

- [ ] **Step 3: Implement** — `PeopleDirectory.swift`

```swift
import Foundation
import SwiftData

/// Finding, creating and tidying people. Names are matched loosely:
/// case, extra spaces, underscores (`to:priya_s`) and diacritics don't matter.
public enum PeopleDirectory {

    public static func normalize(_ name: String) -> String {
        words(name).joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// How a typed name is stored: underscores become spaces, each word starts uppercase.
    public static func displayName(_ typed: String) -> String {
        words(typed).map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }

    /// Index of the person `typed` refers to: exact match first, else the only prefix match.
    public static func match(_ typed: String, in names: [String]) -> Int? {
        let key = normalize(typed)
        guard !key.isEmpty else { return nil }
        let keys = names.map(normalize)
        if let exact = keys.firstIndex(of: key) { return exact }
        let prefixed = keys.indices.filter { keys[$0].hasPrefix(key) }
        return prefixed.count == 1 ? prefixed[0] : nil
    }

    public static func findOrCreate(_ typed: String, in context: ModelContext) throws -> Person {
        var people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        return findOrCreate(typed, among: &people, in: context)
    }

    /// Moves `duplicate`'s entries onto `keeper`, fills details the keeper lacks, deletes the duplicate.
    public static func merge(_ duplicate: Person, into keeper: Person, in context: ModelContext) {
        let moved = duplicate.entries ?? []
        for entry in moved { entry.person = keeper }
        if keeper.team == nil { keeper.team = duplicate.team }
        if keeper.role == .other { keeper.role = duplicate.role }
        keeper.isSorted = keeper.isSorted || duplicate.isSorted
        context.delete(duplicate)
    }

    /// Combines people whose names match (e.g. created offline on two devices). Oldest wins.
    public static func mergeDuplicates(in context: ModelContext) throws {
        let people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        var keepers: [String: Person] = [:]
        for person in people {
            let key = normalize(person.name)
            if let keeper = keepers[key] {
                merge(person, into: keeper, in: context)
            } else {
                keepers[key] = person
            }
        }
    }

    /// Links entries captured before people existed (`from:` text only). Safe to run repeatedly.
    public static func backfillFromText(in context: ModelContext) throws {
        var people = try context.fetch(FetchDescriptor<Person>(sortBy: [SortDescriptor(\.createdAt)]))
        for entry in try context.fetch(FetchDescriptor<Entry>()) where entry.person == nil && entry.linkRaw == nil {
            guard let from = entry.from, !words(from).isEmpty else { continue }
            entry.person = findOrCreate(from, among: &people, in: context)
            entry.link = .from
        }
    }

    /// Deletes a person; their entries stay as R's own (waiting items become R's tasks again).
    /// `from` text is cleared too, so backfill can't recreate the person.
    public static func delete(_ person: Person, in context: ModelContext) {
        for entry in person.entries ?? [] {
            entry.link = nil
            entry.from = nil
        }
        context.delete(person)
    }

    /// Run at launch and whenever the app comes to the foreground.
    public static func tidy(in context: ModelContext) throws {
        try backfillFromText(in: context)
        try mergeDuplicates(in: context)
        try context.save()
    }

    /// The `from:` / `to:` token being typed at the end of `text`, if any.
    public static func completionToken(in text: String) -> (keyword: String, partial: String)? {
        guard let last = text.split(separator: " ", omittingEmptySubsequences: false).last else { return nil }
        for keyword in ["from:", "to:"] where last.lowercased().hasPrefix(keyword) {
            return (keyword, String(last.dropFirst(keyword.count)))
        }
        return nil
    }

    /// Indexes of names starting with `partial` (all names when empty), up to `limit`.
    public static func completions(for partial: String, in names: [String], limit: Int = 5) -> [Int] {
        let key = normalize(partial)
        return Array(names.indices.filter { key.isEmpty || normalize(names[$0]).hasPrefix(key) }.prefix(limit))
    }

    // MARK: Private

    private static func words(_ s: String) -> [String] {
        s.replacingOccurrences(of: "_", with: " ").split(whereSeparator: \.isWhitespace).map(String.init)
    }

    private static func findOrCreate(_ typed: String, among people: inout [Person], in context: ModelContext) -> Person {
        if let i = match(typed, in: people.map(\.name)) { return people[i] }
        let person = Person(name: displayName(typed))
        context.insert(person)
        people.append(person)
        return person
    }
}
```

- [ ] **Step 4: Run all core tests**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add DayfoldCore
git commit -m "Core: PeopleDirectory (match, merge, backfill, delete, completions)"
```

### Task 3: Review rules for waiting items

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/Review.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/WaitingReviewTests.swift`

**Interfaces:**
- Consumes: `DayPageItem.isWaiting`, `Entry.person/link/delegatedAt/nudgedAt`, `Person` (Task 1), `makeContainer()` (Task 1 tests).
- Produces:
  - `ReviewAction.nudged`
  - `Review.pending(_:on:calendar:)` now excludes waiting items
  - `Review.waitingDays<Item: DayPageItem>(_ item: Item, on day: Date, calendar: Calendar = .current) -> Int`
  - `Review.staleWaiting<Item: DayPageItem>(_ items: [Item], on day: Date, after days: Int, calendar: Calendar = .current) -> [Item]`
  - `Review.queue<Item: DayPageItem>(_ items: [Item], on day: Date, nudgeAfter days: Int, calendar: Calendar = .current) -> [Item]`
  - `Review.delegate(_ entry: Entry, to person: Person, now: Date = Date())`

- [ ] **Step 1: Write the failing tests** — `WaitingReviewTests.swift`

```swift
import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

private let cal: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Asia/Kolkata")!
    return c
}()

private func day(_ d: Int, _ h: Int = 9) -> Date {
    cal.date(from: DateComponents(year: 2026, month: 10, day: d, hour: h))!   // 19 = Monday
}

private func waiting(created: Date, delegated: Date? = nil, nudged: Date? = nil) -> FakeItem {
    FakeItem(createdAt: created, showOn: cal.startOfDay(for: created),
             link: .to, delegatedAt: delegated, nudgedAt: nudged)
}

@Suite("Waiting items in Review")
struct WaitingReviewTests {

    @Test("Own pending review excludes waiting items")
    func pendingExcludesWaiting() {
        let own = FakeItem(createdAt: day(19), showOn: cal.startOfDay(for: day(19)))
        let theirs = waiting(created: day(19), delegated: day(19))
        #expect(Review.pending([own, theirs], on: day(19), calendar: cal).count == 1)
    }

    @Test("Stale is whole calendar days, inclusive: Mon 18:00 → Thu 09:00 is 3 days")
    func staleBoundary() {
        let w = waiting(created: day(19, 10), delegated: day(19, 18))
        #expect(Review.waitingDays(w, on: day(22, 9), calendar: cal) == 3)
        #expect(Review.staleWaiting([w], on: day(22, 9), after: 3, calendar: cal).count == 1)
        #expect(Review.staleWaiting([w], on: day(21, 9), after: 3, calendar: cal).isEmpty)
    }

    @Test("Nudging restarts the clock")
    func nudgeResets() {
        let w = waiting(created: day(19), delegated: day(19), nudged: day(21))
        #expect(Review.waitingDays(w, on: day(22), calendar: cal) == 1)
        #expect(Review.staleWaiting([w], on: day(22), after: 3, calendar: cal).isEmpty)
    }

    @Test("Queue is own tasks first, then stale waiting, oldest wait first")
    func queueOrder() {
        let own = FakeItem(createdAt: day(22), showOn: cal.startOfDay(for: day(22)))
        let older = waiting(created: day(12), delegated: day(12))
        let newer = waiting(created: day(17), delegated: day(17))
        let q = Review.queue([newer, own, older], on: day(22), nudgeAfter: 3, calendar: cal)
        #expect(q.count == 3)
        #expect(q[0].isWaiting == false)
        #expect(q[1].createdAt == day(12) && q[2].createdAt == day(17))
    }
}

@Suite("Delegate and nudge actions") @MainActor
struct DelegateActionTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test("Delegate links the person, marks waiting, keeps who asked as text")
    func delegateKeepsAskedBy() {
        let priya = Person(name: "Priya"), arjun = Person(name: "Arjun")
        let e = Entry(text: "Q4 numbers")
        [priya, arjun].forEach(context.insert); context.insert(e)
        e.person = priya; e.link = .from
        e.status = .inProgress

        let now = day(20, 11)
        Review.delegate(e, to: arjun, now: now)
        #expect(e.person?.id == arjun.id)
        #expect(e.link == .to && e.isWaiting)
        #expect(e.delegatedAt == now && e.nudgedAt == nil)
        #expect(e.status == .open)
        #expect(e.from == "Priya")
    }

    @Test func nudgedSetsTimestampOnly() {
        let e = Entry(text: "x")
        context.insert(e)
        Review.apply(.nudged, to: e, now: day(21), calendar: cal)
        #expect(e.nudgedAt == day(21) && e.status == .open && e.closedAt == nil)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/WaitingReviewTests -only-testing:DayfoldCoreTests/DelegateActionTests`
Expected: build failure — `type 'ReviewAction' has no member 'nudged'`.

- [ ] **Step 3: Implement** — in `Review.swift`

Add the case to `ReviewAction` (after `drop`):

```swift
    /// Followed up on a waiting item today. Restarts its waiting clock.
    case nudged
```

Replace `pending` and add the new functions inside `enum Review`:

```swift
    /// R's own tasks needing a decision tonight: active, visible on `day`, not waiting on someone.
    public static func pending<Item: DayPageItem>(_ items: [Item], on day: Date, calendar: Calendar = .current) -> [Item] {
        items.filter { $0.kind == .task && $0.status.isActive && !$0.isWaiting && DayPage.contains($0, on: day, calendar: calendar) }
    }

    /// Whole days a waiting item has waited since the last follow-up (else delegation, else capture).
    public static func waitingDays<Item: DayPageItem>(_ item: Item, on day: Date, calendar: Calendar = .current) -> Int {
        let since = calendar.startOfDay(for: item.nudgedAt ?? item.delegatedAt ?? item.createdAt)
        let to = calendar.startOfDay(for: day)
        return max(0, calendar.dateComponents([.day], from: since, to: to).day ?? 0)
    }

    /// Waiting items that have waited `days` or more, oldest wait first.
    public static func staleWaiting<Item: DayPageItem>(_ items: [Item], on day: Date, after days: Int, calendar: Calendar = .current) -> [Item] {
        items
            .filter { $0.isWaiting && DayPage.contains($0, on: day, calendar: calendar) && waitingDays($0, on: day, calendar: calendar) >= days }
            .sorted { waitingDays($0, on: day, calendar: calendar) > waitingDays($1, on: day, calendar: calendar) }
    }

    /// Tonight's Review: own tasks, then stale waiting items.
    public static func queue<Item: DayPageItem>(_ items: [Item], on day: Date, nudgeAfter days: Int, calendar: Calendar = .current) -> [Item] {
        pending(items, on: day, calendar: calendar) + staleWaiting(items, on: day, after: days, calendar: calendar)
    }

    /// Hand a task to someone. Keeps "who asked" as `from` text when it came from another person.
    public static func delegate(_ entry: Entry, to person: Person, now: Date = Date()) {
        if entry.link == .from, let askedBy = entry.person?.name { entry.from = askedBy }
        entry.person = person
        entry.link = .to
        entry.delegatedAt = now
        entry.nudgedAt = nil
        entry.status = .open
        entry.closedAt = nil
    }
```

In `apply(_:to:now:calendar:)` add the switch case:

```swift
        case .nudged:
            entry.nudgedAt = now
```

- [ ] **Step 4: Run all core tests**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: all pass (including the existing "Pending review" test — it has no waiting items).

- [ ] **Step 5: Commit**

```bash
git add DayfoldCore
git commit -m "Core: waiting items in Review (stale, queue, nudged, delegate)"
```

---

### Task 4: Person page queries

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/PersonPage.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/PersonPageTests.swift`

**Interfaces:**
- Consumes: Task 1 model, `Review.waitingDays` (Task 3).
- Produces:
  - `Person.owed: [Entry]` (active tasks, `link == .from`, oldest first)
  - `Person.waiting: [Entry]` (active tasks, `link == .to`, oldest first)
  - `Person.notes: [Entry]` (notes, `link == .about`, newest first)
  - `Person.oldestWaitingDays(on: Date, calendar: Calendar = .current) -> Int?`
  - `struct WaitingGroup: Identifiable { let person: Person; let entries: [Entry]; let oldestDays: Int }`
  - `PersonPage.allWaiting(_ people: [Person], on day: Date, calendar: Calendar = .current) -> [WaitingGroup]` (non-empty groups, oldest wait first)

- [ ] **Step 1: Write the failing tests** — `PersonPageTests.swift`

```swift
import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@Suite("Person page") @MainActor
struct PersonPageTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    private func entry(_ text: String, _ kind: EntryKind = .task, link: PersonLink, for p: Person, at t: TimeInterval) -> Entry {
        let e = Entry(text: text, kind: kind, createdAt: Date(timeIntervalSince1970: t))
        context.insert(e)
        e.person = p
        e.link = link
        return e
    }

    @Test("Owed, waiting and notes are separated and ordered")
    func sections() {
        let p = Person(name: "Priya"); context.insert(p)
        _ = entry("owe-new", link: .from, for: p, at: 200)
        _ = entry("owe-old", link: .from, for: p, at: 100)
        let done = entry("owe-done", link: .from, for: p, at: 50); done.status = .done
        _ = entry("wait", link: .to, for: p, at: 150)
        _ = entry("note-old", .note, link: .about, for: p, at: 10)
        _ = entry("note-new", .note, link: .about, for: p, at: 300)

        #expect(p.owed.map(\.text) == ["owe-old", "owe-new"])
        #expect(p.waiting.map(\.text) == ["wait"])
        #expect(p.notes.map(\.text) == ["note-new", "note-old"])
    }

    @Test("All waiting groups people with waiting items, oldest wait first")
    func allWaiting() {
        let a = Person(name: "Arjun"), b = Person(name: "Bea"), c = Person(name: "Cy")
        [a, b, c].forEach(context.insert)
        let day0 = Date(timeIntervalSince1970: 1_800_000_000)
        let e1 = entry("a1", link: .to, for: a, at: 0); e1.delegatedAt = day0.addingTimeInterval(-2 * 86_400)
        let e2 = entry("b1", link: .to, for: b, at: 0); e2.delegatedAt = day0.addingTimeInterval(-6 * 86_400)
        _ = entry("c-owe", link: .from, for: c, at: 0)

        let groups = PersonPage.allWaiting([a, b, c], on: day0)
        #expect(groups.map(\.person.name) == ["Bea", "Arjun"])
        #expect(groups[0].oldestDays == 6)
        #expect(a.oldestWaitingDays(on: day0) == 2)
        #expect(c.oldestWaitingDays(on: day0) == nil)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/PersonPageTests`
Expected: build failure — `value of type 'Person' has no member 'owed'`.

- [ ] **Step 3: Implement** — `PersonPage.swift`

```swift
import Foundation
import SwiftData

public extension Person {
    /// What R owes this person: open tasks they asked for, oldest first.
    var owed: [Entry] {
        (entries ?? []).filter { $0.kind == .task && $0.link == .from && $0.status.isActive }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// What R is waiting on this person for, oldest first.
    var waiting: [Entry] {
        (entries ?? []).filter(\.isWaiting).sorted { $0.createdAt < $1.createdAt }
    }

    /// 1:1 notes about this person, newest first.
    var notes: [Entry] {
        (entries ?? []).filter { $0.kind == .note && $0.link == .about }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func oldestWaitingDays(on day: Date, calendar: Calendar = .current) -> Int? {
        waiting.map { Review.waitingDays($0, on: day, calendar: calendar) }.max()
    }
}

public struct WaitingGroup: Identifiable {
    public let person: Person
    public let entries: [Entry]
    public let oldestDays: Int
    public var id: PersistentIdentifier { person.persistentModelID }
}

public enum PersonPage {
    /// Everyone R is waiting on, with their items; longest wait first.
    public static func allWaiting(_ people: [Person], on day: Date, calendar: Calendar = .current) -> [WaitingGroup] {
        people.compactMap { person in
            let items = person.waiting
            guard let oldest = person.oldestWaitingDays(on: day, calendar: calendar), !items.isEmpty else { return nil }
            return WaitingGroup(person: person, entries: items, oldestDays: oldest)
        }
        .sorted { $0.oldestDays > $1.oldestDays }
    }
}
```

- [ ] **Step 4: Run all core tests**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add DayfoldCore
git commit -m "Core: person page queries and all-waiting groups"
```

---

### Task 5: Capture parser `to:` and name cleanup

**Files:**
- Modify: `DayfoldCore/Sources/DayfoldCore/CaptureParser.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/CaptureParserTests.swift` (add tests)

**Interfaces:**
- Produces: `ParsedCapture.to: String?` (declared last, default `nil`, so the existing memberwise init in tests still compiles). `from` and `to` are stripped of trailing `.,;:!?)`.

- [ ] **Step 1: Add failing tests** to `CaptureParserTests`

```swift
    @Test func extractsTo() {
        let p = CaptureParser.parse("Q4 capacity numbers to:arjun", now: now, calendar: cal)
        #expect(p.text == "Q4 capacity numbers")
        #expect(p.to == "arjun")
        #expect(p.from == nil)
    }

    @Test func fromAndToTogether() {
        let p = CaptureParser.parse("Deck from:meera to:priya_s", now: now, calendar: cal)
        #expect(p.from == "meera" && p.to == "priya_s")
    }

    @Test("Trailing punctuation is not part of a name")
    func trailingPunctuation() {
        let p = CaptureParser.parse("Ping to:arjun, about from:priya.", now: now, calendar: cal)
        #expect(p.to == "arjun" && p.from == "priya")
        #expect(p.text == "Ping about")
    }

    @Test func emptyToIsKeptAsText() {
        let p = CaptureParser.parse("walk to: the office", now: now, calendar: cal)
        #expect(p.to == nil)
        #expect(p.text == "walk to: the office")
    }
```

- [ ] **Step 2: Run to verify it fails**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/CaptureParserTests`
Expected: build failure — `value of type 'ParsedCapture' has no member 'to'`.

- [ ] **Step 3: Implement**

In `ParsedCapture`, add as the **last** stored property:

```swift
    /// `to:name` — waiting on this person.
    public var to: String? = nil
```

Update the doc comment list with `to:arjun → to (waiting on)`.

In `parse`, declare `var to: String?` next to `from`, replace the `from:` line and add `to:` right after it:

```swift
            if lower.hasPrefix("from:"), let name = personName(token.dropFirst(5)) { from = name; continue }
            if lower.hasPrefix("to:"), let name = personName(token.dropFirst(3)) { to = name; continue }
```

Return with `to`:

```swift
        return ParsedCapture(text: kept.joined(separator: " "), scope: scope, from: from, dueOn: dueOn, tags: tags, to: to)
```

Add the helper inside `CaptureParser`:

```swift
    /// A person token without trailing punctuation; nil when nothing is left.
    private static func personName(_ raw: Substring) -> String? {
        let name = raw.trimmingCharacters(in: CharacterSet(charactersIn: ".,;:!?)"))
        return name.isEmpty ? nil : name
    }
```

- [ ] **Step 4: Run all core tests**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: all pass, including the existing `plainTextPassesThrough` equality test.

- [ ] **Step 5: Commit**

```bash
git add DayfoldCore
git commit -m "Core: to: in capture parser, strip punctuation from names"
```

---

### Task 6: App wiring — schema, tidy, capture linking and autocomplete

**Files:**
- Modify: `dayfold/MyApp.swift`
- Modify: `dayfold/DemoData.swift` (container line only)
- Modify: `dayfold/Views/CaptureBar.swift`

**Interfaces:**
- Consumes: `PeopleDirectory.findOrCreate/tidy/completionToken/completions`, `Review.delegate`, `ParsedCapture.to`.
- Produces: `CaptureBar(filter:day:focus:linkedTo:)` where `linkedTo: (person: Person, link: PersonLink)? = nil` (used by Task 9's person page).

- [ ] **Step 1: Register `Person` and tidy on launch/foreground** — `MyApp.swift`

Change the schema line to:

```swift
        let schema = Schema([Entry.self, Person.self])
```

Add to `DayfoldApp`:

```swift
    @Environment(\.scenePhase) private var scenePhase
```

Attach to the `WindowGroup(id: "main") { … }` scene, right after `.modelContainer(container)`:

```swift
        .onChange(of: scenePhase, initial: true) { _, phase in
            // Link legacy from: text and merge people duplicated across devices.
            if phase == .active { try? PeopleDirectory.tidy(in: container.mainContext) }
        }
```

In `DemoData.container()` change the container line to:

```swift
        let container = try! ModelContainer(for: Entry.self, Person.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
```

- [ ] **Step 2: Capture links people and offers completions** — `CaptureBar.swift`

Add properties:

```swift
    @Query(sort: \Person.name) private var people: [Person]
    /// Set on a person page: every capture links to this person this way.
    var linkedTo: (person: Person, link: PersonLink)? = nil
```

(Place `linkedTo` after `var focus`. Existing call sites stay valid.)

Wrap the existing outer `HStack(alignment: .bottom, spacing: 8) { … }` in a `VStack(spacing: 6)` with the strip on top, and move the `.padding/.background/.overlay/.dynamicTypeSize` modifiers onto the `VStack`:

```swift
        VStack(alignment: .leading, spacing: 6) {
            if !suggestions.isEmpty { suggestionStrip }
            HStack(alignment: .bottom, spacing: 8) {
                // … existing content unchanged …
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
```

Hide the task/note toggle when linked (the person page decides kind): wrap the kind `Button { kind = … }` in `if linkedTo == nil { … }`.

Replace the `TextField` prompt with:

```swift
                TextField(placeholder, text: $text, axis: .vertical)
```

Add these members:

```swift
    private var placeholder: String {
        guard let linkedTo else { return kind == .task ? "What did someone ask you for?" : "Write a note…" }
        let first = linkedTo.person.name.split(separator: " ").first.map(String.init) ?? linkedTo.person.name
        switch linkedTo.link {
        case .from: return "Something you owe \(first)…"
        case .to: return "Waiting on \(first) for…"
        case .about: return "Note about \(first)…"
        }
    }

    /// People matching a trailing from:/to: token, most recently used first.
    private var suggestions: [Person] {
        guard linkedTo == nil, let token = PeopleDirectory.completionToken(in: text) else { return [] }
        let recent = people.sorted { lastUsed($0) > lastUsed($1) }
        return PeopleDirectory.completions(for: token.partial, in: recent.map(\.name)).map { recent[$0] }
    }

    private func lastUsed(_ person: Person) -> Date {
        (person.entries ?? []).map(\.createdAt).max() ?? person.createdAt
    }

    private var suggestionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(suggestions) { person in
                    Button { complete(with: person) } label: {
                        Text(person.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .frame(minHeight: 32)
                            .background(Color.card, in: Capsule())
                            .overlay(Capsule().strokeBorder(.separator, lineWidth: 0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .transition(.opacity)
    }

    private func complete(with person: Person) {
        guard let token = PeopleDirectory.completionToken(in: text) else { return }
        text = String(text.dropLast(token.keyword.count + token.partial.count))
            + token.keyword + person.name.replacingOccurrences(of: " ", with: "_") + " "
    }

    private func link(_ entry: Entry, _ parsed: ParsedCapture) {
        if let linkedTo {
            if linkedTo.link == .to {
                Review.delegate(entry, to: linkedTo.person)
            } else {
                entry.person = linkedTo.person
                entry.link = linkedTo.link
            }
        } else if let to = parsed.to, let person = try? PeopleDirectory.findOrCreate(to, in: context) {
            Review.delegate(entry, to: person)   // to: wins; from text stays on the entry
        } else if let from = parsed.from, let person = try? PeopleDirectory.findOrCreate(from, in: context) {
            entry.person = person
            entry.link = .from
        }
    }
```

In `save()`, make the kind respect a 1:1 link and call `link` after insert:

```swift
        let entry = Entry(
            text: parsed.text,
            kind: linkedTo?.link == .about ? .note : kind,
            scope: parsed.scope ?? scope,
            createdAt: Date(),
            showOn: Calendar.current.isDateInToday(day) ? nil : day,
            dueOn: parsed.dueOn,
            from: parsed.from,
            tags: parsed.tags
        )
        withAnimation(.snappy) {
            context.insert(entry)
            link(entry, parsed)
        }
```

- [ ] **Step 3: Build both platforms**

Run the two build commands from Global Constraints.
Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 4: Run core tests** (nothing in core changed, sanity only)

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS`
Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add dayfold
git commit -m "App: Person in schema, tidy on foreground, capture links people with autocomplete"
```

---

### Task 7: People picker, Delegate action, waiting rows

**Files:**
- Create: `dayfold/Views/People/PeoplePicker.swift`
- Modify: `dayfold/Views/EntryRow.swift`
- Modify: `dayfold/Views/DayPageView.swift`

**Interfaces:**
- Consumes: `Review.delegate`, `Review.waitingDays`, `PeopleDirectory.normalize/displayName/findOrCreate`, `Entry.isWaiting`.
- Produces:
  - `PeoplePicker(title: String, excluding: Person? = nil, onPick: (Person) -> Void)`
  - `PersonLabel(person: Person)` (initials avatar + name + "team · role")
  - `PersonRole.title: String`
  - `EntryRow(entry:day:showScope:onToggle:onPerson:)` with `var onPerson: ((Person) -> Void)? = nil` declared **after** `onToggle` so existing trailing-closure calls still bind to `onToggle`.

- [ ] **Step 1: Create `PeoplePicker.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// Search, pick, or add a person. Used by Delegate and Merge.
struct PeoplePicker: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.name) private var people: [Person]
    @State private var search = ""
    let title: String
    var excluding: Person? = nil
    let onPick: (Person) -> Void

    private var key: String { PeopleDirectory.normalize(search) }
    private var candidates: [Person] {
        people.filter { $0.id != excluding?.id && (key.isEmpty || PeopleDirectory.normalize($0.name).contains(key)) }
    }
    /// "Add …" only when picking for delegation and nobody has exactly this name.
    private var canAdd: Bool {
        excluding == nil && !key.isEmpty && !people.contains { PeopleDirectory.normalize($0.name) == key }
    }

    var body: some View {
        NavigationStack {
            List {
                if canAdd {
                    Button { pick(try? PeopleDirectory.findOrCreate(search, in: context)) } label: {
                        Label("Add “\(PeopleDirectory.displayName(search))”", systemImage: "person.badge.plus")
                    }
                }
                ForEach(candidates) { person in
                    Button { pick(person) } label: { PersonLabel(person: person) }
                        .buttonStyle(.plain)
                }
            }
            .searchable(text: $search, prompt: "Name")
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        .frame(minWidth: 360, minHeight: 420)
    }

    private func pick(_ person: Person?) {
        guard let person else { return }
        onPick(person)
        dismiss()
    }
}

/// Initials avatar, name, and "team · role".
struct PersonLabel: View {
    let person: Person
    @ScaledMetric(relativeTo: .body) private var avatar: CGFloat = 32

    var body: some View {
        HStack(spacing: 10) {
            Text(initials)
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
                .frame(width: avatar, height: avatar)
                .background(Color.accentColor.opacity(0.15), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    private var initials: String {
        PeopleDirectory.displayName(person.name).split(separator: " ").prefix(2)
            .compactMap(\.first).map(String.init).joined()
    }

    private var subtitle: String {
        [person.team, person.role.title].compactMap { $0 }.joined(separator: " · ")
    }
}

extension PersonRole {
    var title: String {
        switch self {
        case .report: "Direct report"
        case .manager: "Manager"
        case .peer: "Peer"
        case .other: "Other"
        }
    }
}
```

- [ ] **Step 2: Waiting mark and person name in `EntryRow.swift`**

Add after `let onToggle: () -> Void`:

```swift
    /// Tapping the person's name (e.g. open their page). Nil = plain text.
    var onPerson: ((Person) -> Void)? = nil
```

In `mark`, before the existing `if isTask {` add a waiting branch (turn the existing `if isTask` into `else if isTask`):

```swift
        if entry.isWaiting {
            Button(action: onToggle) {
                Image(systemName: "arrow.forward.circle")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: markSize, height: markSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Got it — mark delivered")
        } else if isTask {
```

In `meta`, replace the `if let from = entry.from, !from.isEmpty { Text("· \(from)") }` block with:

```swift
            if let person = entry.person, let link = entry.link {
                personName(person, waiting: link == .to)
            } else if let from = entry.from, !from.isEmpty {
                Text("· \(from)")
            }
```

Replace the age badge condition so waiting items show how long they've waited:

```swift
            if isTask && entry.status.isActive {
                let days = entry.isWaiting ? Review.waitingDays(entry, on: day) : age
                if days > 0 { AgeBadge(days: days) }
            }
```

Add:

```swift
    @ViewBuilder
    private func personName(_ person: Person, waiting: Bool) -> some View {
        let label = Text(waiting ? "· ⇢ \(person.name)" : "· \(person.name)")
        if let onPerson {
            Button { onPerson(person) } label: { label.underline() }
                .buttonStyle(.plain)
                .accessibilityHint("Opens \(person.name)")
        } else {
            label
        }
    }
```

- [ ] **Step 3: Delegate action on the day page** — `DayPageView.swift`

Add state:

```swift
    @State private var delegating: Entry?
```

In `.swipeActions(edge: .leading)`, change the Done label so waiting items read "Got it":

```swift
                                    entry.status.isActive
                                        ? Label(entry.isWaiting ? "Got it" : "Done", systemImage: "checkmark")
                                        : Label("Reopen", systemImage: "arrow.uturn.backward")
```

In `.swipeActions(edge: .trailing)`, inside the existing `if`, add after the Tomorrow button:

```swift
                                if !entry.isWaiting {
                                    Button { delegating = entry } label: { Label("Delegate", systemImage: "person.crop.circle.badge.arrow.forward") }
                                        .tint(.orange)
                                }
```

In `menu(for:)`, inside `else if !isPast { … }` after Drop:

```swift
                Button(entry.isWaiting ? "Delegate to Someone Else…" : "Delegate to…",
                       systemImage: "person.crop.circle.badge.arrow.forward") { delegating = entry }
```

Next to the other `.sheet` modifiers:

```swift
            .sheet(item: $delegating) { entry in
                PeoplePicker(title: "Delegate to") { person in
                    withAnimation(.snappy) { Review.delegate(entry, to: person) }
                }
            }
```

- [ ] **Step 4: Build both platforms**

Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 5: Commit**

```bash
git add dayfold
git commit -m "App: people picker, Delegate action, waiting rows with person names"
```

---

### Task 8: Review — waiting cards, Delegate, nudge setting

**Files:**
- Modify: `dayfold/Views/DayPageView.swift` (review queue)
- Modify: `dayfold/Views/ReviewView.swift`
- Modify: `dayfold/Views/SettingsView.swift`

**Interfaces:**
- Consumes: `Review.queue`, `Review.waitingDays`, `ReviewAction.nudged`, `Review.delegate`, `PeoplePicker` (Task 7).
- Produces: `@AppStorage("review.nudgeAfter")` (Int, default 3) read by DayPageView and written by Settings.

- [ ] **Step 1: Queue includes stale waiting items** — `DayPageView.swift`

Add:

```swift
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
```

Replace `pendingReview`:

```swift
    /// Tonight's Review: own tasks, then waiting items past the nudge threshold.
    private var pendingReview: [Entry] { Review.queue(allEntries, on: today, nudgeAfter: nudgeAfter) }
```

- [ ] **Step 2: Review view changes** — `ReviewView.swift`

Add state:

```swift
    @State private var delegating = false
```

In `body`, inside the scrolling `VStack(spacing: 24)`, between `progress` and the card `ZStack`:

```swift
                            if queue[index].isWaiting {
                                Label("Waiting on others · \(queue.filter(\.isWaiting).count)",
                                      systemImage: "arrow.forward.circle")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.orange)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
```

Add the delegate sheet next to the date-picker sheet:

```swift
            .sheet(isPresented: $delegating) {
                PeoplePicker(title: "Delegate to") { person in
                    guard !finished else { return }
                    withAnimation(reduceMotion ? .default : .snappy(duration: 0.3)) {
                        Review.delegate(queue[index], to: person)
                        tally["delegated", default: 0] += 1
                        index += 1
                    }
                }
            }
```

In `card(_:)`, replace the top `HStack(alignment: .top) { … }` with:

```swift
            HStack(alignment: .top) {
                pairLayout {
                    if entry.isWaiting, let person = entry.person {
                        Label("Waiting on \(person.name)", systemImage: "arrow.forward.circle")
                            .foregroundStyle(.orange)
                        if let team = person.team { Text(team) }
                    } else {
                        Label(entry.scope == .work ? "Work" : "Personal",
                              systemImage: entry.scope == .work ? "briefcase" : "house")
                        if let from = entry.person?.name ?? entry.from, !from.isEmpty { Text("from \(from)") }
                    }
                }
                Spacer(minLength: 8)
                let days = entry.isWaiting ? Review.waitingDays(entry, on: today) : DayPage.age(of: entry, on: today)
                if days > 0 { AgeBadge(days: days) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
```

Replace the whole `actions` property with:

```swift
    @ViewBuilder
    private var actions: some View {
        if !finished, queue[index].isWaiting {
            waitingActions(queue[index])
        } else {
            ownActions
        }
    }

    private var ownActions: some View {
        VStack(spacing: 12) {
            Button { decide(.done, "done") } label: {
                Label("Done", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 32)
                    .foregroundStyle(Color.paper)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            pairLayout {
                Button { decide(.stillGoing, "still going") } label: {
                    Label("Still going", systemImage: "circle.lefthalf.filled").frame(maxWidth: .infinity, minHeight: 32)
                }
                laterMenu("Push to…", delegate: true)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) { decide(.drop, "dropped") } label: {
                Text("Drop").frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.delete, modifiers: .command)
        }
        .controlSize(.large)
    }

    private func waitingActions(_ entry: Entry) -> some View {
        VStack(spacing: 12) {
            Button { decide(.done, "got it") } label: {
                Label("Got it", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 32)
                    .foregroundStyle(Color.paper)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            pairLayout {
                Button { decide(.nudged, "nudged") } label: {
                    Label("Nudged today", systemImage: "bell").frame(maxWidth: .infinity, minHeight: 32)
                }
                laterMenu("Follow up on…", delegate: false)
            }
            .buttonStyle(.bordered)

            HStack {
                ShareLink(item: followUpMessage(entry)) {
                    Label("Message…", systemImage: "square.and.arrow.up")
                }
                Spacer()
                Button(role: .destructive) { decide(.drop, "dropped") } label: { Text("Drop") }
                    .keyboardShortcut(.delete, modifiers: .command)
            }
            .buttonStyle(.borderless)
            .frame(minHeight: 44)
        }
        .controlSize(.large)
    }

    private func laterMenu(_ title: String, delegate: Bool) -> some View {
        Menu {
            Button("Tomorrow") { decide(.push(to: tomorrow), "pushed") }
            Button("Next Monday") { decide(.push(to: nextMonday), "pushed") }
            Divider()
            Button("Pick a date…") { pickingDate = true }
            if delegate {
                Divider()
                Button("Delegate to…") { delegating = true }
            }
        } label: {
            Label(title, systemImage: "arrow.turn.down.right").frame(maxWidth: .infinity, minHeight: 32)
        }
        .menuIndicator(.hidden)
    }

    private func followUpMessage(_ entry: Entry) -> String {
        let first = entry.person?.name.split(separator: " ").first.map(String.init) ?? "there"
        return "Hi \(first), checking in on: \(entry.text)"
    }
```

In `summary`, change the tally key list to:

```swift
                Text(["done", "got it", "still going", "pushed", "delegated", "nudged", "dropped"]
```

- [ ] **Step 3: Nudge setting** — `SettingsView.swift`

Add:

```swift
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
```

In the "Evening review" section, after the days `VStack`:

```swift
                Stepper(value: $nudgeAfter, in: 1...14) {
                    LabeledContent("Nudge after", value: nudgeAfter == 1 ? "1 day" : "\(nudgeAfter) days")
                }
```

Change the section footer's non-empty text to:

```swift
                     : "A reminder to fold today's open tasks into tomorrow. Things you're waiting on join Review once they've waited this long.")
```

- [ ] **Step 4: Build both platforms**

Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 5: Commit**

```bash
git add dayfold
git commit -m "App: Review waiting cards, Delegate in Review, nudge-after setting"
```

---

### Task 9: People screens — list, person page, editor, all waiting

**Files:**
- Create: `dayfold/Views/People/PeopleListView.swift`
- Create: `dayfold/Views/People/PersonView.swift`
- Create: `dayfold/Views/People/PersonEditor.swift`
- Create: `dayfold/Views/People/AllWaitingView.swift`
- Modify: `dayfold/Views/DayPageView.swift` (open a person from a row)

**Interfaces:**
- Consumes: `Person.owed/waiting/notes/oldestWaitingDays`, `PersonPage.allWaiting`, `PeopleDirectory.merge/delete`, `PeoplePicker`, `PersonLabel`, `PersonRole.title`, `EntryRow(...onPerson:)`, `CaptureBar(...linkedTo:)`.
- Produces: `PeopleListView(team: String? = nil)`, `PersonView(person:)`, `PersonEditor(person:onRemoved:)`, `AllWaitingView()` — used by Task 10.

- [ ] **Step 1: `PeopleListView.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// Everyone R works with, grouped by role. Mac sidebar team rows pass `team`.
struct PeopleListView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
    var team: String? = nil
    @State private var teamFilter: String?

    private let today = Calendar.current.startOfDay(for: Date())
    private var teams: [String] { Array(Set(people.compactMap(\.team))).sorted() }
    private var shown: [Person] {
        guard let selected = team ?? teamFilter else { return people }
        return people.filter { $0.team == selected }
    }
    private var unsorted: [Person] { shown.filter { !$0.isSorted } }
    private var groups: [(title: String, people: [Person])] {
        [("Direct reports", shown.filter { $0.role == .report }),
         ("Manager", shown.filter { $0.role == .manager }),
         ("Peers & others", shown.filter { $0.role == .peer || $0.role == .other })]
            .filter { !$0.people.isEmpty }
    }

    var body: some View {
        List {
            if team == nil, !teams.isEmpty {
                Picker("Team", selection: $teamFilter.animation(.snappy)) {
                    Text("All").tag(String?.none)
                    ForEach(teams, id: \.self) { Text($0).tag(String?.some($0)) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            if !unsorted.isEmpty {
                Section("Unsorted · \(unsorted.count)") { ForEach(unsorted) { row($0) } }
            }
            ForEach(groups, id: \.title) { group in
                Section(group.title) { ForEach(group.people) { row($0) } }
            }
            if people.isEmpty {
                ContentUnavailableView("No people yet", systemImage: "person.2",
                                       description: Text("Type from:name or to:name when you capture, and people appear here."))
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .navigationTitle(team ?? "People")
        .navigationDestination(for: Person.self) { PersonView(person: $0) }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink { AllWaitingView() } label: { Label("Waiting", systemImage: "arrow.forward.circle") }
            }
        }
        #endif
    }

    private func row(_ person: Person) -> some View {
        NavigationLink(value: person) {
            HStack(spacing: 6) {
                PersonLabel(person: person)
                Spacer(minLength: 4)
                let owed = person.owed.count
                if owed > 0 { CountPill(text: "\(owed) owe", stale: false) }
                if let days = person.oldestWaitingDays(on: today) {
                    CountPill(text: "\(person.waiting.count) waiting · \(days)d", stale: days >= nudgeAfter)
                }
            }
        }
        .listRowBackground(Color.card)
    }
}

/// Small count capsule; amber when something has waited too long.
struct CountPill: View {
    let text: String
    let stale: Bool

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold).monospacedDigit())
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .foregroundStyle(stale ? Color.orange : Color.accentColor)
            .background((stale ? Color.orange : Color.accentColor).opacity(0.14), in: Capsule())
    }
}
```

- [ ] **Step 2: `PersonView.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// One person: what R owes them, what R is waiting on, and 1:1 notes. Capture is pre-linked.
struct PersonView: View {
    @Bindable var person: Person
    @Environment(\.dismiss) private var dismiss
    @State private var link: PersonLink = .from
    @State private var editing = false
    @FocusState private var captureFocused: Bool

    private let today = Calendar.current.startOfDay(for: Date())
    private var first: String { person.name.split(separator: " ").first.map(String.init) ?? person.name }
    private var isEmpty: Bool { person.owed.isEmpty && person.waiting.isEmpty && person.notes.isEmpty }

    var body: some View {
        List {
            header
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            section("You owe \(first)", person.owed)
            section("Waiting on \(first)", person.waiting)
            section("1:1 notes", person.notes)
            if isEmpty {
                Text("Nothing yet. Capture below — choose I owe, Waiting or 1:1 note.")
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Picker("Capture as", selection: $link) {
                    Text("I owe").tag(PersonLink.from)
                    Text("Waiting").tag(PersonLink.to)
                    Text("1:1 note").tag(PersonLink.about)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .padding(.horizontal, 12)
                .padding(.top, 8)
                CaptureBar(filter: .all, day: Date(), focus: $captureFocused, linkedTo: (person, link))
            }
            .background(.bar)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) { Button("Edit") { editing = true } }
        }
        #if os(iOS)
        .toolbarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $editing) { PersonEditor(person: person) { dismiss() } }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text([person.team, person.role.title].compactMap { $0 }.joined(separator: " · "))
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(1.2)
                .foregroundStyle(.tint)
            Text(person.name)
                .font(.system(.largeTitle, design: .serif, weight: .semibold))
            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var summary: String {
        var parts = ["\(person.owed.count) you owe", "\(person.waiting.count) waiting"]
        if let last = person.notes.first {
            parts.append("last note \(last.createdAt.formatted(.relative(presentation: .named)))")
        }
        return parts.joined(separator: " · ")
    }

    @ViewBuilder
    private func section(_ title: String, _ entries: [Entry]) -> some View {
        if !entries.isEmpty {
            Section {
                ForEach(entries) { entry in
                    EntryRow(entry: entry, day: today) { toggle(entry) }
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 20))
                        .listRowBackground(Color.clear)
                }
            } header: {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func toggle(_ entry: Entry) {
        withAnimation(.snappy) {
            if entry.status.isActive { Review.apply(.done, to: entry) } else { Review.reopen(entry) }
        }
    }
}
```

- [ ] **Step 3: `PersonEditor.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// Name, role, team; merge or delete. Saving marks the person as sorted.
struct PersonEditor: View {
    @Bindable var person: Person
    /// Called before a merge/delete so the person page can close first.
    var onRemoved: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false
    @State private var merging = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $person.name)
                }
                Section {
                    Picker("Role", selection: $person.role) {
                        ForEach(PersonRole.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    TextField("Team", text: Binding(
                        get: { person.team ?? "" },
                        set: {
                            let team = $0.trimmingCharacters(in: .whitespaces)
                            person.team = team.isEmpty ? nil : team
                        }
                    ), prompt: Text("e.g. Platform"))
                }
                Section {
                    Button("Merge with…") { merging = true }
                    Button("Delete \(person.name)…", role: .destructive) { confirmDelete = true }
                } footer: {
                    Text("Merging moves everything onto the other person. Deleting keeps entries, unlinked.")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        person.isSorted = true
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Delete \(person.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    remove { PeopleDirectory.delete(person, in: context) }
                }
            } message: {
                Text("\(person.entries?.count ?? 0) entries stay, unlinked.")
            }
            .sheet(isPresented: $merging) {
                PeoplePicker(title: "Merge into", excluding: person) { keeper in
                    remove { PeopleDirectory.merge(person, into: keeper, in: context) }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 360)
    }

    /// Close this sheet and the person page, then change the store, so no view reads a deleted person.
    private func remove(_ change: @escaping () -> Void) {
        dismiss()
        onRemoved()
        DispatchQueue.main.async {
            withAnimation { change() }
            try? context.save()
        }
    }
}
```

- [ ] **Step 4: `AllWaitingView.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// Everything R is waiting on, grouped by person, longest wait first.
struct AllWaitingView: View {
    @Query(sort: \Person.name) private var people: [Person]
    @State private var opened: Person?
    private let today = Calendar.current.startOfDay(for: Date())

    var body: some View {
        let groups = PersonPage.allWaiting(people, on: today)
        List {
            ForEach(groups) { group in
                Section("\(group.person.name) · \(group.oldestDays)d") {
                    ForEach(group.entries) { entry in
                        EntryRow(entry: entry, day: today, showScope: false) {
                            withAnimation(.snappy) { Review.apply(.done, to: entry) }
                        } onPerson: { opened = $0 }
                    }
                }
            }
            if groups.isEmpty {
                ContentUnavailableView("Not waiting on anyone", systemImage: "checkmark.circle",
                                       description: Text("Delegate a task or type to:name to track it here."))
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .navigationTitle("Waiting")
        .navigationDestination(item: $opened) { PersonView(person: $0) }
    }
}
```

- [ ] **Step 5: Open a person from the day page** — `DayPageView.swift`

Add:

```swift
    @State private var openedPerson: Person?
```

Change the row construction to pass `onPerson`:

```swift
                    EntryRow(entry: entry, day: day, showScope: filter == .all) { toggle(entry) } onPerson: { openedPerson = $0 }
```

Add next to the sheets (inside the `NavigationStack`):

```swift
            .navigationDestination(item: $openedPerson) { PersonView(person: $0) }
```

- [ ] **Step 6: Build both platforms**

Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 7: Commit**

```bash
git add dayfold
git commit -m "App: people list, person page, editor with merge/delete, all waiting"
```

---

### Task 10: Navigation — tabs on iPhone, sidebar on Mac

**Files:**
- Create: `dayfold/Views/RootView.swift`
- Modify: `dayfold/MyApp.swift` (`DayPageView()` → `RootView()` inside `WindowGroup`)

**Interfaces:**
- Consumes: `DayPageView`, `PeopleListView(team:)`, `AllWaitingView` (Task 9), `ReviewReminder.shared` (unchanged).

- [ ] **Step 1: `RootView.swift`**

```swift
import SwiftUI
import SwiftData
import DayfoldCore

/// iPhone: Today and People tabs. Mac: sidebar with Today, People, teams, and All waiting.
struct RootView: View {
    #if os(macOS)
    enum SidebarItem: Hashable { case today, people, team(String), waiting }

    @Query(sort: \Person.name) private var people: [Person]
    @State private var selection: SidebarItem? = .today
    private var teams: [String] { Array(Set(people.compactMap(\.team))).sorted() }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("Today", systemImage: "calendar").tag(SidebarItem.today)
                Label("People", systemImage: "person.2").tag(SidebarItem.people)
                if !teams.isEmpty {
                    Section("Teams") {
                        ForEach(teams, id: \.self) { team in
                            Label(team, systemImage: "person.3").tag(SidebarItem.team(team))
                        }
                    }
                }
                Section("Waiting") {
                    Label("All waiting", systemImage: "arrow.forward.circle").tag(SidebarItem.waiting)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch selection ?? .today {
            case .today: DayPageView()
            case .people: NavigationStack { PeopleListView() }
            case .team(let team): NavigationStack { PeopleListView(team: team) }.id(team)
            case .waiting: NavigationStack { AllWaitingView() }
            }
        }
    }
    #else
    var body: some View {
        TabView {
            DayPageView()
                .tabItem { Label("Today", systemImage: "calendar") }
            NavigationStack { PeopleListView() }
                .tabItem { Label("People", systemImage: "person.2") }
        }
    }
    #endif
}
```

- [ ] **Step 2: Use it** — in `MyApp.swift` replace `DayPageView()` inside `WindowGroup(id: "main") { … }` with `RootView()` (keep the `.task { … }` modifier on it).

- [ ] **Step 3: Build both platforms**

Expected: `** BUILD SUCCEEDED **` twice.

- [ ] **Step 4: Commit**

```bash
git add dayfold
git commit -m "App: tabs on iPhone, sidebar on Mac"
```

---

### Task 11: Demo data, visual verification, docs

**Files:**
- Modify: `dayfold/DemoData.swift`
- Modify: `CLAUDE.md` (state + layout lines), `docs/spec.md` (decisions log)

- [ ] **Step 1: Demo people** — in `DemoData.container()`, after the existing samples are inserted and before `return container`:

```swift
        let ctx = container.mainContext
        let priya = Person(name: "Priya Sharma", role: .report, team: "Platform")
        let arjun = Person(name: "Arjun", role: .report, team: "Sync")
        let sam = Person(name: "Sam K", role: .report, team: "Platform")
        let meera = Person(name: "Meera", role: .manager)
        let hr = Person(name: "HR")                     // unsorted
        [priya, arjun, meera, sam].forEach { $0.isSorted = true }
        [priya, arjun, sam, meera, hr].forEach(ctx.insert)

        func link(_ e: Entry, _ p: Person, _ l: PersonLink) { e.person = p; e.link = l }
        link(samples[0], meera, .from)        // Q4 hiring plan, from Meera
        link(samples[1], arjun, .from)        // Arjun's design doc
        link(samples[3], priya, .from)        // migration checklist
        link(samples[5], hr, .from)           // interview feedback (done)
        link(samples[4], sam, .about)         // 1:1 note about Sam

        let capacity = Entry(text: "Q4 capacity numbers", createdAt: at(6, 10, 0))
        let syncDoc = Entry(text: "Sync service rollout plan", createdAt: at(1, 15, 0))
        let vendor = Entry(text: "Vendor security questionnaire", createdAt: at(8, 11, 0))
        [capacity, syncDoc, vendor].forEach(ctx.insert)
        Review.delegate(capacity, to: priya, now: at(6, 10, 5))     // stale
        Review.delegate(syncDoc, to: arjun, now: at(1, 15, 5))      // fresh
        Review.delegate(vendor, to: arjun, now: at(8, 11, 5))
        vendor.nudgedAt = at(2, 9, 0)                               // nudged, not yet stale

        let note = Entry(text: "Wants more ownership of on-call tooling", kind: .note, createdAt: at(0, 12, 30))
        ctx.insert(note); link(note, priya, .about)
```

- [ ] **Step 2: Build and screenshot (iPhone 16 Pro simulator)**

Build for the simulator, install, then launch with `-demo` and capture: day page (light, dark), People tab, a person page (tap Priya), Review with `-review` (should include the "Q4 capacity numbers" waiting card after own tasks), largest Dynamic Type for the person page, iPhone SE for the People tab. Check against the spec's Screens section and the checklist: ⇢ waiting mark amber, person names underlined/tappable, no truncation at accessibility sizes, 44pt targets, both themes readable. Fix anything off in the owning view and re-shoot.

Mac: `open` the Debug build with `--args -demo` and check the sidebar (Today, People, Platform, Sync, All waiting) by window screenshot only (`screencapture -l <windowid>`), never a full-screen capture.

- [ ] **Step 3: Full verification**

Run: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS` → all pass.
Run both app builds in Debug **and** `-configuration Release` → four `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Docs**

`CLAUDE.md` State section: replace the v0.1 bullets with a "People & delegation done" line naming `Person.swift`, `PeopleDirectory.swift`, `PersonPage.swift`, `Views/People/*`, `RootView.swift`, and the CloudKit production-schema reminder. Layout section: add `dayfold/Views/People/`.

`docs/spec.md` decisions log, append:

```markdown
- 2026-10-18 People & delegation: Person model (role, optional team) linked one-per-entry
  via from / to / about; to:name + Delegate action; stale waiting items join evening
  Review after N days (default 3). iPhone tabs, Mac sidebar. Spec:
  docs/superpowers/specs/2026-10-18-people-delegation-design.md
- Before the first TestFlight build: deploy the CloudKit schema (Person + new Entry fields)
  to production in the CloudKit Console.
```

- [ ] **Step 5: Commit**

```bash
git add dayfold CLAUDE.md docs/spec.md
git commit -m "People & delegation: demo data, docs"
```
