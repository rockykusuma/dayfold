import SwiftUI
import LocalAuthentication

/// Optional Face ID / Touch ID / passcode lock for journal content. Relocks when the app goes to the background
/// (Mac: when it stops being the active app). While the app isn't active, content is also covered (`isObscured`).
@Observable final class JournalLock {
    static let shared = JournalLock()
    static let storageKey = "journal.lock"

    #if os(macOS)
    // ponytail: observers live as long as the shared instance (the app); never removed.
    private init() {
        let center = NotificationCenter.default
        center.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated { JournalLock.shared.appActive(false); JournalLock.shared.lock() }
        }
        center.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            MainActor.assumeIsolated { JournalLock.shared.appActive(true) }
        }
    }
    #else
    private init() {}
    #endif

    /// The Settings toggle. Stored in UserDefaults; registered with Observation so locked views update when it flips.
    /// Reads false without a device passcode (nothing could ever unlock it), so nothing is hidden.
    var isEnabled: Bool {
        get {
            access(keyPath: \.isEnabled)
            #if DEBUG
            if CommandLine.arguments.contains("-locked") { return true }   // screenshots of the locked state
            #endif
            return Self.canAuthenticate && UserDefaults.standard.bool(forKey: Self.storageKey)
        }
        set { withMutation(keyPath: \.isEnabled) { UserDefaults.standard.set(newValue, forKey: Self.storageKey) } }
    }
    private(set) var isUnlocked = false
    var isLocked: Bool { isEnabled && !isUnlocked }
    /// App not active (app switcher snapshot, Control Center, the auth prompt itself). Visual only: never clears `isUnlocked`.
    private(set) var isObscured = false
    /// What views check before showing journal content: locked, or the lock is on and the app isn't active.
    var isHidden: Bool { isEnabled && (!isUnlocked || isObscured) }
    /// An auth prompt is up; the Unlock button and the toggle wait.
    private(set) var isAuthenticating = false

    /// A device passcode is set, so `.deviceOwnerAuthentication` can succeed.
    // ponytail: asked on every read (passcode can change while the app runs); cache it if it ever shows up in profiles.
    static var canAuthenticate: Bool { LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) }

    func unlock() async -> Bool {
        guard Self.canAuthenticate else { isUnlocked = true; return true }   // no passcode: nothing to check against
        guard !isAuthenticating else { return false }
        isAuthenticating = true
        defer { isAuthenticating = false }
        let ok = (try? await LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your journal")) ?? false
        // Set after the prompt returns, so a lock() fired while the prompt made the app resign can't undo a success.
        if ok { isUnlocked = true }
        return ok
    }

    func lock() { isUnlocked = false }

    func appActive(_ active: Bool) { isObscured = !active }

    static var toggleTitle: String {
        let context = LAContext()
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else { return "Lock with passcode" }
        switch context.biometryType {
        case .faceID: return "Lock with Face ID"
        case .touchID: return "Lock with Touch ID"
        default: return "Lock with passcode"
        }
    }
}

extension View {
    /// Covers journal content while locked. The content stays mounted underneath, so an open editor keeps its draft
    /// and sheets it presented stay up; unlocking reveals everything unchanged.
    func journalLockCover() -> some View { modifier(JournalLockCover()) }
}

private struct JournalLockCover: ViewModifier {
    func body(content: Content) -> some View {
        let lock = JournalLock.shared
        content
            .disabled(lock.isLocked)       // drops keyboard focus; only when really locked, not just inactive
            .accessibilityHidden(lock.isHidden)
            .overlay { if lock.isHidden { JournalLockedView() } }
    }
}

/// Lock glyph, "Journal locked", "Unlock".
struct JournalLockedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            Text("Journal locked")
                .font(.system(.title3, design: .serif, weight: .semibold))
            Button { Task { _ = await JournalLock.shared.unlock() } } label: {
                Text("Unlock").foregroundStyle(Color.paper).frame(minWidth: 120)
            }
            .disabled(JournalLock.shared.isAuthenticating)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paper.ignoresSafeArea())
        .contentShape(Rectangle())   // taps never reach the content underneath
    }
}
