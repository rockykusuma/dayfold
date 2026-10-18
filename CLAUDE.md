# Dayfold — notes for Claude Code

Open-source Mac + iPhone daily log / bullet journal with automatic carry-forward.
Owner drives Xcode; Claude writes code and reviews. Read `docs/spec.md` first.

## Layout
- `dayfold/` — SwiftUI app target (iOS 17 / macOS 14). Synchronized folder: new files are picked up automatically.
- `dayfold/Views/` — screens. `DayPageView.swift` is the root screen.
- `DayfoldCore/` — local Swift package, **no UI**: `Entry` model, `DayPage` rule, `Review` actions, `CaptureParser`, Swift Testing tests. Language mode 5.
- `docs/spec.md` — v0.1 spec + decisions log. Append decisions there.

## Rules
- SwiftData + CloudKit automatic sync: every `Entry` property has a default or is optional; no `@Attribute(.unique)`; enums stored as raw strings. Don't break this.
- Carry-forward is a query (`DayPage.contains`), never a copy. Put logic in `DayfoldCore` with tests; views stay thin.
- Both platforms from one codebase; prefer APIs available on iOS 17 and macOS 14.
- Container `iCloud.com.rockykusuma.dayfold`, bundle id `com.rockykusuma.dayfold.app`. Push Notifications capability deferred — re-add `aps-environment` to `dayfold/dayfold.entitlements` when enabled.
- Don't commit `xcuserdata`. Don't run `swift test` outside Xcode for the package (SwiftData is Apple-only); use ⌘U on the `DayfoldCore` scheme.

## State as of 2026-10-18 night
- Today screen done: `Views/DayPageView.swift` (day nav ‹ › ⌘←/⌘→, date picker, scope toggle, swipe + context actions, edit sheet), `Views/ReviewView.swift` (card stack, four actions, progress; opened via toolbar / ⌘R). `ContentView` deleted; app launches `DayPageView`.
- Builds on macOS + iOS Simulator; DayfoldCore tests pass (run from `DayfoldCore/`: `xcodebuild test -scheme DayfoldCore -destination platform=macOS`).
- Not yet written: notification scheduling (default 18:30 weekdays, tap opens Review), Settings, Mac menu-bar capture item.
