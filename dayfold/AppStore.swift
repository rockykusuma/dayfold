import SwiftData
import DayfoldCore

/// The one model container, shared by the app's scenes and App Intents so both write to the same store.
enum AppStore {
    @MainActor static let container: ModelContainer = {
        #if DEBUG
        if DemoData.isEnabled { return DemoData.container() }
        #endif
        let schema = Schema([Entry.self, Person.self, ChecklistItem.self, DayNote.self, JournalEntry.self, JournalPhoto.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.rockykusuma.dayfold")
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
