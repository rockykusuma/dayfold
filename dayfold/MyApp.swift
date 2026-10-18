import SwiftUI
import SwiftData
import DayfoldCore

@main
struct DayfoldApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Entry.self])
        let config = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private("iCloud.com.rockykusuma.dayfold")
        )
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DayPageView()
        }
        .modelContainer(container)
    }
}
