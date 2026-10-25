import SwiftUI
import SwiftData
import DayfoldCore
import UserNotifications

@main
struct DayfoldApp: App {
    let container: ModelContainer
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Set before launch finishes so a tap that cold-launches the app still opens Review.
        UNUserNotificationCenter.current().delegate = ReviewReminder.shared
        #if DEBUG
        if DemoData.isEnabled {
            container = DemoData.container()
            ReviewReminder.shared.showReview = CommandLine.arguments.contains("-review")
            return
        }
        #endif
        let schema = Schema([Entry.self, Person.self, ChecklistItem.self])
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
        WindowGroup(id: "main") {
            RootView()
                .task {
                    #if DEBUG
                    if DemoData.isEnabled { return }
                    #endif
                    await ReviewReminder.shared.schedule()
                }
        }
        .modelContainer(container)
        .commands { CaptureCommands() }
        .onChange(of: scenePhase, initial: true) { _, phase in
            // Link legacy from: text, merge duplicate people, remove duplicate repeats.
            if phase == .active { try? Maintenance.tidy(in: container.mainContext) }
        }

        #if os(macOS)
        Settings { SettingsView() }

        MenuBarExtra("Dayfold", systemImage: "pencil.line") {
            MenuBarCapture()
                .modelContainer(container)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}
