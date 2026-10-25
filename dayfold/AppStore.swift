import SwiftData
import DayfoldCore
#if DEBUG
import CoreData
#endif

/// The one model container, shared by the app's scenes and App Intents so both write to the same store.
enum AppStore {
    @MainActor static let container: ModelContainer = {
        #if DEBUG
        if DemoData.isEnabled { return DemoData.container() }
        #endif
        let types: [any PersistentModel.Type] = [Entry.self, Person.self, ChecklistItem.self, DayNote.self,
                                                 JournalEntry.self, JournalPhoto.self, NotePage.self]
        let schema = Schema(types)
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudKitID)
        )
        #if DEBUG
        if CommandLine.arguments.contains("-initCloudKitSchema") { initializeCloudKitSchema(types, at: config.url) }
        #endif
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static let cloudKitID = "iCloud.com.rockykusuma.dayfold"

    #if DEBUG
    /// `-initCloudKitSchema` (run once from Xcode, signed into iCloud): writes every record type and field to the CloudKit
    /// *Development* schema, so "Deploy Schema Changes…" has the complete schema even for types never saved yet.
    /// Apple's recipe: a Core Data CloudKit container over the same store, then removed before SwiftData opens it.
    private static func initializeCloudKitSchema(_ types: [any PersistentModel.Type], at url: URL) {
        do {
            try autoreleasepool {
                guard let model = NSManagedObjectModel.makeManagedObjectModel(for: types) else { return }
                let description = NSPersistentStoreDescription(url: url)
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitID)
                description.shouldAddStoreAsynchronously = false
                let container = NSPersistentCloudKitContainer(name: "Dayfold", managedObjectModel: model)
                container.persistentStoreDescriptions = [description]
                container.loadPersistentStores { _, error in if let error { fatalError("CloudKit schema: \(error)") } }
                try container.initializeCloudKitSchema()
                for store in container.persistentStoreCoordinator.persistentStores {
                    try container.persistentStoreCoordinator.remove(store)
                }
            }
            print("CloudKit schema initialized")
        } catch {
            print("CloudKit schema failed: \(error)")
        }
    }
    #endif
}
