#if os(macOS)
import Carbon.HIToolbox
import Observation

/// Choices for the system-wide quick-capture shortcut. Settings stores the raw value.
enum QuickCaptureHotkey: String, CaseIterable {
    case off, ctrlOptSpace, ctrlOptD

    static let storageKey = "capture.hotkey"
    static let `default` = Self.ctrlOptSpace

    var title: String {
        switch self {
        case .off: "Off"
        case .ctrlOptSpace: "⌃⌥Space"
        case .ctrlOptD: "⌃⌥D"
        }
    }

    fileprivate var keyCode: Int? {
        switch self {
        case .off: nil
        case .ctrlOptSpace: kVK_Space
        case .ctrlOptD: kVK_ANSI_D
        }
    }
}

/// One system-wide hotkey through Carbon: works in the sandbox, no Accessibility permission.
@Observable final class HotKey {
    static let shared = HotKey()

    /// True when RegisterEventHotKey failed, usually because another app holds the combination.
    private(set) var conflict = false

    @ObservationIgnored private var ref: EventHotKeyRef?
    @ObservationIgnored private var handler: EventHandlerRef?
    // ponytail: one stored action, because the Carbon callback is a C function pointer and can't capture.
    @ObservationIgnored private var action: (() -> Void)?

    /// Replaces the current hotkey. `.off` registers nothing.
    func apply(_ choice: QuickCaptureHotkey, action: @escaping () -> Void) {
        if let ref { UnregisterEventHotKey(ref) }
        ref = nil
        conflict = false
        self.action = action
        guard let keyCode = choice.keyCode else { return }
        installHandler()
        let id = EventHotKeyID(signature: 0x4446_4C44, id: 1) // 'DFLD'
        let status = RegisterEventHotKey(UInt32(keyCode), UInt32(controlKey | optionKey), id,
                                         GetApplicationEventTarget(), 0, &ref)
        if status != noErr {
            ref = nil
            conflict = true
        }
    }

    private func installHandler() {
        guard handler == nil else { return }
        var pressed = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            // The application event target delivers on the main thread.
            MainActor.assumeIsolated { HotKey.shared.action?() }
            return noErr
        }, 1, &pressed, nil, &handler)
    }
}
#endif
