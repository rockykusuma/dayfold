import SwiftUI
import Observation
import DayfoldCore

/// Lets ⌘N (and anything else) ask for a fresh capture on Today.
/// `RootView` switches to Today; `DayPageView` (possibly built after the request) consumes `pending`
/// on appear and on change, then focuses the capture bar.
@Observable
final class CaptureRouter {
    static let shared = CaptureRouter()

    private(set) var requests = 0
    private(set) var pending = false

    func request() { requests += 1; pending = true }
    func consume() { pending = false }
}

extension EntryScope {
    /// The scope the capture bar last used (`capture.lastScope`), work by default.
    static var lastUsed: EntryScope {
        EntryScope(rawValue: UserDefaults.standard.string(forKey: "capture.lastScope") ?? "") ?? .work
    }
}

/// File ▸ New Entry (⌘N) from any screen; reopens the main window on Mac if it was closed.
struct CaptureCommands: Commands {
    #if os(macOS)
    @Environment(\.openWindow) private var openWindow
    #endif

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Entry") {
                #if os(macOS)
                if !NSApp.windows.contains(where: { $0.canBecomeMain && $0.isVisible }) { openWindow(id: "main") }
                #endif
                CaptureRouter.shared.request()
            }
            .keyboardShortcut("n")
        }
    }
}
