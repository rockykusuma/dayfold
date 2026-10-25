# Capture Everywhere Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Capture into Dayfold from anywhere: global hotkey panel and Services on Mac, Siri/Shortcuts on both, ⌘N from every screen, and list paste/drop.

**Architecture:** One Core capture path (`Capture.add` / `Capture.addLines`) moved out of `CaptureBar.save()` and tested. Every entry point (capture bar, drop, App Intent, Mac Services, hotkey panel) calls it. The model container moves into one shared `AppStore.container` so the App Intent and the Mac delegate use the app's store. No schema changes.

**Tech Stack:** Swift 5 language mode, SwiftUI (iOS 17 / macOS 14), SwiftData + CloudKit, App Intents, AppKit (`NSPanel`, Services), Carbon `RegisterEventHotKey`, Swift Testing.

**Spec:** `docs/superpowers/specs/2026-10-25-capture-everywhere-design.md`

## Global Constraints

- Deployment targets: iOS 17 / macOS 14, one codebase. Mac-only code inside `#if os(macOS)`.
- No new packages, no new Xcode targets, no entitlement or capability changes, no SwiftData model changes.
- Every capture goes through `Capture.add` / `Capture.addLines`; no entry point builds an `Entry` itself.
- Last-used scope is `UserDefaults` key `capture.lastScope` (raw `EntryScope`), default `.work`.
- Copy (verbatim): command "New Entry" (⌘N); intent title "Add to Dayfold"; Siri prompt "What should I add?"; replies "Added “<text>” to today." / "Added <n> entries to today."; blank error "Nothing to add."; App Shortcut phrases "Add to \(.applicationName)", "Capture in \(.applicationName)", "New \(.applicationName) entry"; Settings row "Quick capture" with "Off", "⌃⌥Space", "⌃⌥D"; conflict text "In use by another app — pick another"; Services menu "Add to Dayfold".
- SF Symbol for the shortcut: `square.and.pencil`.
- Tests: `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS` (focus: `-only-testing:DayfoldCoreTests/<Suite>`). Never `swift test`.
- After every task that touches `dayfold/`, both builds pass:
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'platform=macOS' build CODE_SIGNING_ALLOWED=NO`
  `xcodebuild -project dayfold.xcodeproj -scheme dayfold -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
- Commit trailers (every commit):
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`
  `Claude-Session: https://claude.ai/code/session_016KuWvS3f2pThajg7yChjq9`
- Core tests: `import Foundation`, `import SwiftData`, `import Testing`, `@testable import DayfoldCore`; `@MainActor` suites with `makeContainer()` (PeopleModelTests.swift) and the `ist` calendar / `at(y,m,d,h)` helper (TestSupport.swift). 2026-10-19 is a Monday.

## Review Focus

1. **Pasted text with `\r\n` line endings or trailing spaces** (copied from Windows mail, Slack): one clean entry per line, no `\r` in any text. Test `crlf` in Task 1.
2. **A line that is only a marker** (`- `, `[ ]`, `3.`): skipped, never an empty entry. Test `markerOnlyLine` in Task 1.
3. **Text that starts like a marker but isn't** (`-5 degrees outside`, `1.5kg flour`, `*important*`): kept verbatim. Test `notAMarker` in Task 1.
4. **Parser tokens through `addLines`** (`Call Sam from:Meera tomorrow #ops`): same result as the capture bar (from link, due date, tag). Test `linesParse` in Task 1.
5. **Pressing the hotkey a second time, or after the panel was closed by clicking away**: the panel toggles and the text field is focused every time it appears. Owner check listed in Task 4 (not unit-testable).

---

### Task 1: Core capture path

**Files:**
- Create: `DayfoldCore/Sources/DayfoldCore/Capture.swift`
- Test: `DayfoldCore/Tests/DayfoldCoreTests/CaptureTests.swift`

**Interfaces:**
- Consumes: `CaptureParser.parse(_:now:calendar:)`, `PeopleDirectory.findOrCreate(_:in:)`, `Review.delegate(_:to:now:)`, `Entry.setRepeat(_:calendar:)` (make it `public` if it is internal), `Entry.init(...)`.
- Produces:
  ```swift
  public enum Capture {
      public struct Link { public let person: Person; public let link: PersonLink
                           public init(person: Person, link: PersonLink) }
      @discardableResult
      public static func add(_ text: String, kind: EntryKind = .task, scope: EntryScope, day: Date,
                             linkedTo: Link? = nil, now: Date = Date(), calendar: Calendar = .current,
                             in context: ModelContext) -> Entry?
      @discardableResult
      public static func addLines(_ text: String, kind: EntryKind = .task, scope: EntryScope, day: Date,
                                  now: Date = Date(), calendar: Calendar = .current,
                                  in context: ModelContext) -> [Entry]
      public static func stripListMarker(_ line: Substring) -> Substring
  }
  ```

Rules (from the spec, all must be tested): text trimmed, blank → nil; kind: `linkedTo.link == .about` → `.note`, parsed `to` or `linkedTo.link == .to` → `.task`, else `kind`; scope: parsed scope ?? `scope`; `createdAt = now`; `showOn` = nil-arg (today) when `calendar.isDate(day, inSameDayAs: now)`, else `day`; linking order `linkedTo` (`.to` → `Review.delegate(entry, to:, now:)`, else set person + link) ▸ parsed `to` (delegate, keep `from` text) ▸ parsed `from` (link `.from`); `isPriority` and `setRepeat(parsed.repeatRule, calendar:)` only when final kind is `.task`. Insert into `context`; do not save (callers save when they need to). `addLines`: split on `\n` (handle `\r\n`), `stripListMarker`, then `add` each in order. `stripListMarker` removes one leading `-`, `*`, `•`, `–`, `[ ]`, `[x]`, `[X]`, or `<digits>.` / `<digits>)` **only when followed by whitespace**, plus that whitespace; otherwise returns the line unchanged.

- [ ] **Step 1: Write the failing tests** in `CaptureTests.swift`, suite `CaptureTests` (`@Suite("Capture") @MainActor`), `now = at(2026,10,19,10)`, `calendar: ist`:
  - `blank`: `add("   ", …)` is nil and the store has 0 entries.
  - `basicTask`: `add("Send deck", scope: .work, day: now)` → kind `.task`, scope `.work`, `createdAt == now`, `showOn == at(2026,10,19)`.
  - `futureDay`: `day: at(2026,10,22,15)` → `showOn == at(2026,10,22)`.
  - `parsedScopeWins`: `"Buy milk #personal"` with `scope: .work` → `.personal`, text `"Buy milk"`.
  - `kindRules`: `add("x", kind: .note, …)` → note; `add("Deck to:Ravi", kind: .note, …)` → task, delegated to person "Ravi" (`link == .to`, `delegatedAt == now`); `linkedTo: .init(person: p, link: .about)` with `kind: .task` → note; `linkedTo` `.to` with `kind: .note` → task, delegated.
  - `fromLinks`: `"Review doc from:Meera"` → `person?.name == "Meera"`, `link == .from`, `from == "Meera"`.
  - `toKeepsFrom`: `"Deck from:Meera to:Ravi"` → delegated to Ravi, `from == "Meera"`.
  - `priorityRepeatTasksOnly`: `"Standup notes ! every:day"` task → `isPriority`, `repeatRule == .daily`; same text with `kind: .note` → `isPriority == false`, `repeatRule == nil`.
  - `linesSplit`: `addLines("- one\n* two\n\n• three\n[ ] four\n[x] five\n1. six\n2) seven\n– eight", …)` → texts `["one","two","three","four","five","six","seven","eight"]` in that order.
  - `crlf`: `addLines("one  \r\ntwo\r\n", …)` → texts `["one","two"]`, none contains `"\r"`.
  - `markerOnlyLine`: `addLines("- \n[ ]\n3.\nreal", …)` → texts `["real"]`.
  - `notAMarker`: `stripListMarker("-5 degrees outside") == "-5 degrees outside"`, `stripListMarker("1.5kg flour") == "1.5kg flour"`, `stripListMarker("*important*") == "*important*"`.
  - `singleLineSameAsAdd`: `addLines("Call Sam", …)` returns one entry with text `"Call Sam"`.
  - `linesParse`: `addLines("Call Sam from:Meera tomorrow #ops", …)` → `link == .from`, `dueOn` equals what `CaptureParser.parse(_, now:, calendar: ist).dueOn` gives, `tags == ["ops"]`.

- [ ] **Step 2: Run** `cd DayfoldCore && xcodebuild test -scheme DayfoldCore -destination platform=macOS -only-testing:DayfoldCoreTests/CaptureTests` — expect a compile failure (`Capture` not found).
- [ ] **Step 3: Implement `Capture` in `Capture.swift`** per the rules above.
- [ ] **Step 4: Run the suite, then the full core suite** — expect `** TEST SUCCEEDED **`.
- [ ] **Step 5: Commit** `Capture: one Core path for every entry point` (with trailers).

---

### Task 2: In-app — capture bar, ⌘N everywhere, drop a list

**Files:**
- Modify: `dayfold/Views/CaptureBar.swift` (`save()`, remove `entryKind`/`link` helpers now in Core)
- Create: `dayfold/Views/CaptureRouter.swift`
- Modify: `dayfold/Views/RootView.swift`, `dayfold/Views/DayPageView.swift`, `dayfold/MyApp.swift`

**Interfaces:**
- Consumes: `Capture.add`, `Capture.addLines`, `Capture.Link` (Task 1).
- Produces (in `CaptureRouter.swift`):
  ```swift
  @Observable final class CaptureRouter { static let shared: CaptureRouter
      private(set) var requests = 0
      func request() }               // bumps `requests`
  extension EntryScope { static var lastUsed: EntryScope }   // reads "capture.lastScope", default .work
  ```

- [ ] **Step 1: CaptureBar** — `save()` calls `Capture.addLines` when the trimmed text contains a newline, else `Capture.add` with `kind: kind`, `scope: scope`, `day: day`, `linkedTo: linkedTo.map { Capture.Link(person: $0.person, link: $0.link) }`, inside the existing `withAnimation(.snappy)`. Behaviour must be identical to today for single lines.
- [ ] **Step 2: ⌘N** — in `DayfoldApp.body`, add `.commands { CommandGroup(replacing: .newItem) { Button("New Entry") { … }.keyboardShortcut("n") } }` on the `WindowGroup`. The action calls `CaptureRouter.shared.request()`; on macOS, if no main window is visible (`NSApp.windows` has none that `canBecomeMain` and `isVisible`), also `openWindow(id: "main")` (read `openWindow` via `@Environment` in a small `Commands` struct). RootView: on `CaptureRouter.shared.requests` change, Mac `selection = .today`, iPhone `tab = 0`. DayPageView: on the same change, `day = today` and `captureFocused = true` (defer focus one runloop turn, e.g. `Task { @MainActor in captureFocused = true }`, so it lands after the tab/sidebar switch). Remove `.keyboardShortcut("n", modifiers: .command)` from the toolbar "New" button and make the button call `CaptureRouter.shared.request()`.
- [ ] **Step 3: Drop** — on the day page `List`, when `!isPast`, `.dropDestination(for: String.self) { items, _ in … }`: `Capture.addLines(items.joined(separator: "\n"), scope: filter.defaultScope ?? .lastUsed, day: day, in: context)` with `.snappy` animation; return `true` if any entry was added.
- [ ] **Step 4: Build both platforms** — expect `** BUILD SUCCEEDED **` ×2. Run the full core suite — `** TEST SUCCEEDED **`.
- [ ] **Step 5: Commit** `Capture bar uses Core; ⌘N from any screen; drop a list on the day page`.

---

### Task 3: Siri, Shortcuts, Spotlight — App Intent

**Files:**
- Create: `dayfold/AppStore.swift`, `dayfold/Intents/AddToDayfoldIntent.swift`
- Modify: `dayfold/MyApp.swift` (use `AppStore.container`)

**Interfaces:**
- Consumes: `Capture.addLines` (Task 1), `EntryScope.lastUsed` (Task 2).
- Produces: `enum AppStore { @MainActor static let container: ModelContainer }` — the CloudKit container from today's `DayfoldApp.init` (schema `Entry`, `Person`, `ChecklistItem`, `.private("iCloud.com.rockykusuma.dayfold")`); under `#if DEBUG`, `DemoData.isEnabled` → `DemoData.container()`. `DayfoldApp` uses it; keep the `-review` DEBUG flag and the notification delegate line where they are.

- [ ] **Step 1: `AppStore`** and switch `DayfoldApp` to `AppStore.container` (builds, behaviour unchanged).
- [ ] **Step 2: Intent** — `struct AddToDayfoldIntent: AppIntent`: `title` "Add to Dayfold"; `@Parameter(title: "Text", requestValueDialog: "What should I add?") var text: String`; `@Parameter(title: "Kind", default: .task) var kind: CaptureKind` where `enum CaptureKind: String, AppEnum { case task, note }` (display "Task" / "Note"); `openAppWhenRun = false`. `@MainActor func perform() async throws -> some IntentResult & ProvidesDialog`: `Capture.addLines(text, kind:, scope: .lastUsed, day: Date(), in: AppStore.container.mainContext)`, then `try context.save()`. Zero entries → throw an error whose message is "Nothing to add." One → dialog "Added “\(entry.text)” to today." Many → "Added \(n) entries to today."
- [ ] **Step 3: Shortcuts** — `struct DayfoldShortcuts: AppShortcutsProvider` with one `AppShortcut(intent: AddToDayfoldIntent(), phrases: ["Add to \(.applicationName)", "Capture in \(.applicationName)", "New \(.applicationName) entry"], shortTitle: "Add to Dayfold", systemImageName: "square.and.pencil")`.
- [ ] **Step 4: Build both platforms** — `** BUILD SUCCEEDED **` ×2 (App Intents metadata extraction must not warn about the phrases).
- [ ] **Step 5: Commit** `Siri and Shortcuts: Add to Dayfold`.

---

### Task 4: Mac global hotkey → floating capture panel

**Files:**
- Create: `dayfold/Mac/HotKey.swift`, `dayfold/Mac/QuickCapturePanel.swift`, `dayfold/Mac/MacAppDelegate.swift`
- Modify: `dayfold/MyApp.swift` (`@NSApplicationDelegateAdaptor` on macOS), `dayfold/Views/SettingsView.swift` (Quick capture row, macOS only), `dayfold/Views/MenuBarCapture.swift` (refocus on each show)

**Interfaces:**
- Consumes: `AppStore.container` (Task 3), `MenuBarCapture` (existing).
- Produces:
  ```swift
  enum QuickCaptureHotkey: String, CaseIterable { case off, ctrlOptSpace, ctrlOptD   // "Off", "⌃⌥Space", "⌃⌥D"
      static let storageKey = "capture.hotkey"; static let `default` = Self.ctrlOptSpace }
  @Observable final class HotKey { static let shared: HotKey
      private(set) var conflict = false          // true when RegisterEventHotKey failed
      func apply(_ choice: QuickCaptureHotkey, action: @escaping () -> Void) }
  final class QuickCapturePanel { static let shared: QuickCapturePanel; func toggle() }
  final class MacAppDelegate: NSObject, NSApplicationDelegate   // registers the saved hotkey at launch
  ```

Behaviour: Carbon `RegisterEventHotKey` with `GetApplicationEventTarget()` and one `InstallEventHandler` for `kEventHotKeyPressed`; key codes `kVK_Space` (49) and `kVK_ANSI_D` (2), modifiers `controlKey | optionKey`. `apply` unregisters the previous key first; `.off` registers nothing and clears `conflict`. Panel: an `NSPanel` subclass with `.nonactivatingPanel` + `.titled` + `.fullSizeContentView`, title bar hidden/transparent, `canBecomeKey == true`, `isFloatingPanel`, `level = .floating`, `collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]`, `hidesOnDeactivate = false`, centered in the upper third of the main screen, hosting `MenuBarCapture().modelContainer(AppStore.container)` in an `NSHostingView`. `toggle()`: visible → `orderOut`; else `makeKeyAndOrderFront` and focus the field. Esc (`cancelOperation(_:)`) and losing key status (`windowDidResignKey`) → `orderOut`. Never shows in ⌘Tab or the Dock (the app's regular window behaviour is unchanged).

- [ ] **Step 1: `HotKey` + `QuickCaptureHotkey`.**
- [ ] **Step 2: `QuickCapturePanel`.** `MenuBarCapture` must focus the field every time it appears, not only the first time (e.g. also on `NSWindow.didBecomeKeyNotification` for its window, or an `onAppear`/`onReceive` that sets `focused = true`); the menu-bar panel keeps working as before.
- [ ] **Step 3: `MacAppDelegate`** — `applicationDidFinishLaunching`: `HotKey.shared.apply(saved choice ?? .default) { QuickCapturePanel.shared.toggle() }`. Wire with `@NSApplicationDelegateAdaptor(MacAppDelegate.self)` inside `#if os(macOS)` in `DayfoldApp`.
- [ ] **Step 4: Settings (macOS only)** — new section "Quick capture": `Picker("Quick capture", selection: @AppStorage("capture.hotkey"))` over `QuickCaptureHotkey.allCases` with the display strings; on change call `HotKey.shared.apply`; when `HotKey.shared.conflict`, a footer in orange: "In use by another app — pick another".
- [ ] **Step 5: Build both platforms** — `** BUILD SUCCEEDED **` ×2.
- [ ] **Step 6: Commit** `Mac: global hotkey opens a floating capture panel`.

Owner checks (report in the summary, don't block): ⌃⌥Space from Safari opens the panel with the cursor in the field; Enter adds and keeps it open; Esc and clicking elsewhere close it and Safari is still frontmost; pressing it twice toggles; switching to ⌃⌥D in Settings takes effect immediately.

---

### Task 5: Mac Services "Add to Dayfold" + docs

**Files:**
- Modify: `dayfold/Info.plist` (add `NSServices`), `dayfold/Mac/MacAppDelegate.swift` (provider)
- Modify: `CLAUDE.md`, `docs/spec.md` (decisions log)

**Interfaces:**
- Consumes: `Capture.addLines` (Task 1), `EntryScope.lastUsed` (Task 2), `AppStore.container` (Task 3), `MacAppDelegate` (Task 4).

- [ ] **Step 1: Info.plist** — one `NSServices` item: `NSMenuItem` → `default` = "Add to Dayfold"; `NSMessage` = `addToDayfold`; `NSPortName` = the app's product name (`$(PRODUCT_NAME)`); `NSSendTypes` = [`public.utf8-plain-text`, `NSStringPboardType`]; `NSRequiredContext` = `{}`. Key is ignored on iOS.
- [ ] **Step 2: Provider** — in `applicationDidFinishLaunching` set `NSApp.servicesProvider = self` and call `NSUpdateDynamicServices()`. `@objc func addToDayfold(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>)`: read `pboard.string(forType: .string)`; blank → set `error.pointee` to "Nothing to add." and return; else `Capture.addLines(… scope: .lastUsed, day: Date(), in: AppStore.container.mainContext)` and `try? save()` (log a save failure with `print`-free `os.Logger`, subsystem `com.rockykusuma.dayfold.app`).
- [ ] **Step 3: Docs** — `CLAUDE.md`: Layout gains `Capture.swift` (Core), `CaptureRouter.swift`, `AppStore.swift`, `Intents/`, `Mac/`; State gains "Capture everywhere done" and removes "⌘N capture sheet, global hotkey" from "Not yet". `docs/spec.md` decisions log: one Core capture path; ⌘N replaces File ▸ New; list paste/drop splits lines; App Intent uses last-used scope and today; hotkey presets ⌃⌥Space / ⌃⌥D via Carbon; Services menu; share extension + widgets deferred (need targets + App Group).
- [ ] **Step 4: Build both platforms + full core suite** — `** BUILD SUCCEEDED **` ×2, `** TEST SUCCEEDED **`.
- [ ] **Step 5: Commit** `Mac Services: Add to Dayfold; docs`.

Owner check: Services appear after the app has run once from a built location (`/Applications` or Xcode's build folder); select text in Notes → right-click → Services → "Add to Dayfold" → entry appears on today. If the item is missing, run `/System/Library/CoreServices/pbs -update` once.
