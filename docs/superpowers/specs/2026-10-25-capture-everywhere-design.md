# Capture everywhere — design

Date: 2026-10-25 · Status: owner skipped questions ("just start"); every decision below is Claude's call and open to override.
Roadmap: (1) app icon ✅ → (2) People & delegation ✅ → (3) Find & organise ✅ → **(4) Capture everywhere** → (5) Journal & insights.

## Why

Dayfold only catches what you type into its own window. Asks arrive while you're in Slack, in a
meeting, walking, or reading something on the Mac, and every extra step between "someone asked me"
and "it's in the log" is a chance to forget. This project puts the capture bar one keystroke, one
phrase, or one right-click away from wherever you are, on both Mac and iPhone, without new targets
the owner has to set up in Xcode.

## Goals

1. **Mac, anywhere:** a global hotkey opens a floating capture panel over any app.
2. **Mac, selected text:** right-click → Services → "Add to Dayfold".
3. **iPhone + Mac, hands-free:** Siri / Shortcuts / Spotlight / Action Button: "Add to Dayfold".
4. **Inside the app:** ⌘N works from every screen (not just the day page), and pasting or dropping a
   list makes one entry per line.

## Non-goals (this round)

Share extension, widgets, Control Center controls (iOS 18+), Apple Watch, home-screen quick actions,
notification text replies, email-in, a custom hotkey recorder, link previews. Share extension and
widgets need new Xcode targets plus an App Group; they're the natural follow-up once this lands.

## Anti-goals

- A capture that needs more than "invoke, type, Enter".
- Losing a capture silently: a failed save must say so (intent dialog / visible error).
- A floating panel that gets stuck on screen, steals focus after it closes, or blocks typing elsewhere.
- Parsing that differs by entry point: every path goes through one Core function.
- Anything that breaks the CloudKit sync rules (no schema changes in this project).

## Constraints

Same as the app: iOS 17 / macOS 14 from one codebase; SwiftData + CloudKit; logic in `DayfoldCore`
with Swift Testing tests; views thin; Apple frameworks only (no packages). Calm journal style.

## Core (DayfoldCore) — one capture path

### `Capture.add`
Moves the body of `CaptureBar.save()` into Core so every entry point behaves the same:

```swift
public enum Capture {
    public struct Link { public let person: Person; public let link: PersonLink }
    /// Parses `text` and inserts one entry. Nil for blank text.
    @discardableResult
    public static func add(_ text: String, kind: EntryKind = .task, scope: EntryScope,
                           day: Date, linkedTo: Link? = nil, now: Date = Date(),
                           calendar: Calendar = .current, in context: ModelContext) -> Entry?
    /// One entry per non-blank line (list markers stripped). Returns the inserted entries.
    @discardableResult
    public static func addLines(_ text: String, kind: EntryKind = .task, scope: EntryScope,
                                day: Date, now: Date = Date(), calendar: Calendar = .current,
                                in context: ModelContext) -> [Entry]
    /// "- buy milk" → "buy milk". Strips one leading `-`, `*`, `•`, `–`, `[ ]`, `[x]`, `1.`, `1)`.
    public static func stripListMarker(_ line: Substring) -> Substring
}
```

Rules (unchanged from today's CaptureBar, now tested):
- Kind: `linkedTo.link == .about` → note; parsed `to:` or `linkedTo.link == .to` → task; else `kind`.
- Scope: parsed `#work`/`#personal` wins, else `scope`.
- `showOn`: nil when `day` is today (by `calendar`), else `day`. `createdAt = now`.
- Linking: `linkedTo` (`.to` → `Review.delegate`) ▸ parsed `to:` (delegate; `from` text stays) ▸
  parsed `from:` (link `.from`), people via `PeopleDirectory.findOrCreate`.
- Priority and repeat only when the final kind is task (`setRepeat(_:calendar:)`).
- `addLines`: split on newlines, strip one list marker, trim, skip blank; each line through `add`.
  A single line behaves exactly like `add`.

`CaptureBar.save()` calls `addLines` when the text contains a newline (paste), else `add`.

## Entry points (app target)

### ⌘N everywhere
- `CaptureRouter` (`@Observable`, shared, like `SearchRouter`): `request()` bumps a counter.
- A `New Entry` command (⌘N) replaces the File ▸ New item on Mac (Dayfold is single-window), and
  works with an iPad hardware keyboard. RootView switches to Today on a request; DayPageView jumps
  to today and focuses the capture bar. The toolbar "New" button stays (no duplicate shortcut).

### Paste / drop a list
- Day page (today or future) accepts dropped text (`.dropDestination(for: String.self)`):
  `Capture.addLines` onto that day, scope = the current filter's default or last-used scope.
- Multi-line paste into the capture bar follows the `addLines` rule above.

### Siri, Shortcuts, Spotlight, Action Button — App Intents (iOS 17 / macOS 14)
- `AddToDayfoldIntent`: parameter `text` (String, required; Siri asks "What should I add?"),
  parameter `kind` (Task / Note, default Task). Runs without opening the app. Uses
  `Capture.addLines` on today with the last-used scope (`capture.lastScope`), saves, and replies
  "Added “Call Sam” to today." (or "Added 3 entries to today."). Save failure → throw so Siri /
  Shortcuts shows the error.
- `DayfoldShortcuts: AppShortcutsProvider`: phrases "Add to \(.applicationName)",
  "Capture in \(.applicationName)", "New \(.applicationName) entry"; short title "Add to Dayfold",
  symbol `square.and.pencil`.
- The intent needs the same store as the app: move container creation into
  `AppStore.container` (one static, shared by `DayfoldApp` and the intent; DEBUG `-demo` still
  returns the demo container).

### Mac global hotkey → floating capture panel
- Carbon `RegisterEventHotKey` (works sandboxed, no Accessibility permission).
- Settings ▸ "Quick capture" picker: Off · ⌃⌥Space (default) · ⌃⌥D. If registration fails
  (taken by another app) Settings shows "In use by another app — pick another".
- Pressing it toggles a floating, centered `NSPanel` (Spotlight-like) hosting the existing
  `MenuBarCapture` view: becomes key so you can type immediately, Esc or clicking elsewhere closes
  it and returns focus to the previous app, Enter saves and keeps it open for the next line (same
  as the menu-bar panel). Shows on the active Space; never appears in ⌘Tab.

### Mac Services — "Add to Dayfold"
- `NSServices` entry in `Info.plist` (send types: text), menu title "Add to Dayfold".
- Provider set at launch; handler reads the pasteboard string and calls `Capture.addLines` on today
  with the last-used scope. No window opens; a successful add posts nothing (the menu-bar panel's
  recent list shows it).

## Error handling & sync
- No model changes. All entry points save through the app's single container.
- Intent and Services save immediately (`try context.save()`); errors surface (intent) or are logged
  (Services, which has no UI).

## Testing
Swift Testing in `DayfoldCore/Tests`:
- `Capture.add`: blank → nil; kind rules (about→note, to:→task, linked .to→task); parsed scope wins;
  today → showOn = today, other day → that day; createdAt = now; to: delegates and keeps from text;
  from: links; priority/repeat set on tasks, ignored on notes; linkedTo `.from`/`.about`.
- `addLines`: list markers stripped (each kind), blank lines skipped, single line == `add`, order
  preserved (createdAt ascending or equal, insertion order kept).
- `stripListMarker`: each marker; text that merely starts with `-word` keeps it.
UI/system integrations (hotkey, panel, Services, intent, drop): build on both platforms + owner
checks on device; iOS screenshot pass unaffected.

## Left to the builder
Panel size and placement details, exact dialog wording beyond the above, how the hotkey preference
is stored (`@AppStorage` key `capture.hotkey`), iPad command wiring details.
