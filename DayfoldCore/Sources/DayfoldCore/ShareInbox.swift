import Foundation

/// Hand-off from the iPhone share extension to the app. The extension never opens the store (that would write
/// outside the app's CloudKit sync); it drops one text file per share in the App Group, and the app adds them when it
/// next becomes active.
public enum ShareInbox {
    /// `<App Group>/Inbox`. Nil without the App Group entitlement.
    public static var directory: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: SharedStore.appGroup)?.appending(path: "Inbox")
    }

    /// The shared text plus the page's link (when it isn't already in the text), or nil when there's nothing.
    public static func compose(text: String, url: URL?) -> String? {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let link = url?.absoluteString, !text.contains(link) else { return text.isEmpty ? nil : text }
        return text.isEmpty ? link : text + " " + link
    }

    /// Writes one share as its own file, atomically, so a half-written share is never read.
    public static func add(_ text: String, in dir: URL, now: Date = Date()) throws {
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = String(format: "%.6f-", now.timeIntervalSince1970) + UUID().uuidString + ".txt"
        try Data(text.utf8).write(to: dir.appending(path: name), options: .atomic)
    }

    /// Hands every waiting share to `add` oldest first; each file is deleted only after `add` returns without throwing,
    /// so a failed save leaves it for next time.
    public static func drain(_ dir: URL, into add: (String) throws -> Void) {
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        for file in files.filter({ $0.pathExtension == "txt" }).sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            guard let text = try? String(contentsOf: file, encoding: .utf8) else { continue }
            do { try add(text) } catch { return }
            try? FileManager.default.removeItem(at: file)
        }
    }
}
