#if os(macOS)
import AppKit
import os
import SwiftData
import DayfoldCore

/// Registers the saved quick-capture hotkey at launch.
final class MacAppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let saved = UserDefaults.standard.string(forKey: QuickCaptureHotkey.storageKey)
            .flatMap(QuickCaptureHotkey.init(rawValue:))
        HotKey.shared.apply(saved ?? .default) { QuickCapturePanel.shared.toggle() }
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
    }

    /// Services ▸ "Add to Dayfold" (NSMessage `addToDayfold`).
    @objc func addToDayfold(_ pboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString?>) {
        guard let text = pboard.string(forType: .string),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error.pointee = "Nothing to add."
            return
        }
        let context = AppStore.container.mainContext
        Capture.addLines(text, kind: .task, scope: .lastUsed, day: Date(), in: context)
        do { try context.save() } catch {
            Logger(subsystem: "com.rockykusuma.dayfold.app", category: "services")
                .error("Services save failed: \(error.localizedDescription)")
        }
    }
}
#endif
