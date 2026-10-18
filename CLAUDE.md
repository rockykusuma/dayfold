# Dayfold — notes for Claude Code

Open-source Mac + iPhone daily log / bullet journal with automatic carry-forward.
Owner drives Xcode; Claude writes code and reviews. Read `docs/spec.md` first.

## Layout
- `dayfold/` — SwiftUI app target (iOS 17 / macOS 14). Synchronized folder: new files are picked up automatically.
- `dayfold/Views/` — screens. `DayPageView.swift` is the root screen.
- `dayfold/Views/SearchView.swift`, `SearchRouter.swift` — Search tab/sidebar; `EntryEditor.swift` — edit sheet (priority, repeat, tags, checklist).
- `dayfold/Views/People/` — people list, person page, person editor, all-waiting.
- `DayfoldCore/` — local Swift package, **no UI**: `Entry` model, `DayPage` rule, `Review` actions, `CaptureParser`, `Recurrence`, `Maintenance`, `Search`, `Tags`, `ChecklistItem`, Swift Testing tests. Language mode 5.
- `docs/spec.md` — v0.1 spec + decisions log. Append decisions there.

## Rules
- SwiftData + CloudKit automatic sync: every `Entry` property has a default or is optional; no `@Attribute(.unique)`; enums stored as raw strings. Don't break this.
- Carry-forward is a query (`DayPage.contains`), never a copy. Put logic in `DayfoldCore` with tests; views stay thin.
- Both platforms from one codebase; prefer APIs available on iOS 17 and macOS 14.
- Container `iCloud.com.rockykusuma.dayfold`, bundle id `com.rockykusuma.dayfold.app`. Push Notifications capability is on (CloudKit silent pushes drive live sync); no APNs certificates needed.
- Don't commit `xcuserdata`. Don't run `swift test` outside Xcode for the package (SwiftData is Apple-only); use ⌘U on the `DayfoldCore` scheme.

## Design
- Calm journal look, all native: ink accent (`AccentColor`), `Paper` background, `Card` surfaces — asset-catalog colors with dark variants (`Color.paper`, `Color.card`). Serif (`design: .serif`) for dates, Review card text, empty states; system font elsewhere.
- Bullet marks: ○ task (44pt tap target), – note. Age pill turns amber at 3+ days. Haptics via `.sensoryFeedback`; animations `.snappy`, respect Reduce Motion.
- Debug only: launch with `-demo` for an in-memory sample day (no iCloud, no permission prompt); add `-review` to open Review (`-waiting` starts on the first waiting card), `-settings` for Settings, `-people` (iOS) for the People tab, `-person <Name>` (iOS) for that person's page, `-search [query]` for the Search tab/sidebar with an optional query, `-edit <text prefix>` to open the editor for the first matching entry. `DemoData.swift`.

## State as of 2026-10-18 night
- v0.1 screens done: `DayPageView`, `ReviewView`, `SettingsView`, `ReviewReminder` (see Layout). Mac menu-bar capture: `Views/MenuBarCapture.swift`.
- People & delegation done: `Person.swift`, `PeopleDirectory.swift`, `PersonPage.swift` (DayfoldCore), `Views/People/*`, `RootView.swift` (iPhone tabs, Mac sidebar). Debug flags: `-demo`, `-review`, `-settings`, `-people`.
- Find & organise done: search, tags, checklists, repeating tasks, priority (see spec decisions log).
- Before the first TestFlight build: deploy the CloudKit schema (Person, ChecklistItem + new Entry fields) to production in the CloudKit Console.
- Builds Debug + Release on macOS + iOS. DayfoldCore tests: run from `DayfoldCore/` with `xcodebuild test -scheme DayfoldCore -destination platform=macOS`.
- Not yet: ⌘N capture sheet, global hotkey for the menu-bar panel; notification permission is requested at first launch (consider asking contextually).
