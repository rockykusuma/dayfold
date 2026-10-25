#if os(macOS)
import AppKit

/// Registers the saved quick-capture hotkey at launch.
final class MacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let saved = UserDefaults.standard.string(forKey: QuickCaptureHotkey.storageKey)
            .flatMap(QuickCaptureHotkey.init(rawValue:))
        HotKey.shared.apply(saved ?? .default) { QuickCapturePanel.shared.toggle() }
    }
}
#endif
