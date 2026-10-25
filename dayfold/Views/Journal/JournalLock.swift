import SwiftUI
import LocalAuthentication

/// Optional Face ID / Touch ID / passcode lock for journal content. Relocks when the app goes to the background.
@Observable final class JournalLock {
    static let shared = JournalLock()
    static let storageKey = "journal.lock"

    /// The Settings toggle. Stored in UserDefaults; registered with Observation so locked views update when it flips.
    var isEnabled: Bool {
        get {
            access(keyPath: \.isEnabled)
            #if DEBUG
            if CommandLine.arguments.contains("-locked") { return true }   // screenshots of the locked state
            #endif
            return UserDefaults.standard.bool(forKey: Self.storageKey)
        }
        set { withMutation(keyPath: \.isEnabled) { UserDefaults.standard.set(newValue, forKey: Self.storageKey) } }
    }
    private(set) var isUnlocked = false
    var isLocked: Bool { isEnabled && !isUnlocked }

    func unlock() async -> Bool {
        let ok = (try? await LAContext().evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock your journal")) ?? false
        if ok { isUnlocked = true }
        return ok
    }

    func lock() { isUnlocked = false }

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
        let locked = JournalLock.shared.isLocked
        content
            .disabled(locked)              // drops keyboard focus; nothing behind the cover takes input
            .accessibilityHidden(locked)
            .overlay { if locked { JournalLockedView() } }
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
