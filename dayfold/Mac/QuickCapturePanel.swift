#if os(macOS)
import AppKit
import Carbon.HIToolbox
import SwiftData
import SwiftUI

/// Spotlight-style floating capture for the global hotkey: the menu-bar capture view over any app,
/// without activating Dayfold, so the app you were in stays frontmost.
final class QuickCapturePanel: NSObject, NSWindowDelegate {
    static let shared = QuickCapturePanel()

    private lazy var panel: Panel = {
        let host = NSHostingView(rootView: MenuBarCapture()
            .modelContainer(AppStore.container)
            .ignoresSafeArea()) // content runs under the hidden title bar
        let panel = Panel(contentRect: NSRect(origin: .zero, size: host.fittingSize),
                          styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
                          backing: .buffered, defer: false)
        panel.contentView = host
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            panel.standardWindowButton(button)?.isHidden = true
        }
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        return panel
    }()

    override private init() {
        super.init()
        // "Open Dayfold" activates the app; the panel shouldn't linger over the main window.
        NotificationCenter.default.addObserver(self, selector: #selector(hide),
                                               name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    /// Hotkey action. MenuBarCapture focuses its field whenever its window becomes key.
    func toggle() {
        if panel.isVisible { return hide() }
        if let screen = NSScreen.main?.visibleFrame {
            let size = panel.frame.size
            // Centred in the upper third of the screen.
            panel.setFrameOrigin(NSPoint(x: screen.midX - size.width / 2,
                                         y: screen.maxY - screen.height / 6 - size.height / 2))
        }
        panel.makeKeyAndOrderFront(nil)
    }

    @objc private func hide() { panel.orderOut(nil) }

    /// Clicking anywhere else closes it.
    func windowDidResignKey(_ notification: Notification) { hide() }
}

private final class Panel: NSPanel {
    override var canBecomeKey: Bool { true }

    override func cancelOperation(_ sender: Any?) { orderOut(nil) }

    /// Esc closes even when the text view would keep it (e.g. for completion), unless an input method is composing.
    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, Int(event.keyCode) == kVK_Escape,
           (firstResponder as? NSTextInputClient)?.hasMarkedText() != true {
            return cancelOperation(nil)
        }
        super.sendEvent(event)
    }
}
#endif
