import AppIntents
import SwiftData
import DayfoldCore

enum CaptureKind: String, AppEnum {
    case task, note

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Kind"
    static let caseDisplayRepresentations: [CaptureKind: DisplayRepresentation] = [
        .task: "Task",
        .note: "Note",
    ]

    var entryKind: EntryKind { self == .note ? .note : .task }
}

struct NothingToAdd: Error, CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource { "Nothing to add." }
}

struct AddToDayfoldIntent: AppIntent {
    static let title: LocalizedStringResource = "Add to Dayfold"
    static let openAppWhenRun = false

    @Parameter(title: "Text", requestValueDialog: "What should I add?")
    var text: String

    @Parameter(title: "Kind", default: .task)
    var kind: CaptureKind

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = AppStore.container.mainContext
        let entries = Capture.addLines(text, kind: kind.entryKind, scope: .lastUsed, day: Date(), in: context)
        guard let first = entries.first else { throw NothingToAdd() }
        try context.save()
        if entries.count == 1 {
            return .result(dialog: "Added “\(first.text)” to today.")
        }
        return .result(dialog: "Added \(entries.count) entries to today.")
    }
}

struct DayfoldShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddToDayfoldIntent(),
            phrases: [
                "Add to \(.applicationName)",
                "Capture in \(.applicationName)",
                "New \(.applicationName) entry",
            ],
            shortTitle: "Add to Dayfold",
            systemImageName: "square.and.pencil"
        )
    }
}
