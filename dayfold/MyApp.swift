import SwiftUI
import SwiftData
import DayfoldCore
import UserNotifications

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
        // Set before launch finishes so a tap that cold-launches the app still opens Review.
        UNUserNotificationCenter.current().delegate = ReviewReminder.shared
    }

    var body: some Scene {
        WindowGroup {
            DayPageView()
                .task { await ReviewReminder.shared.schedule() }
        }
        .modelContainer(container)
    }
}
