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
            ReviewReminder.shared.showReview = CommandLine.arguments.contains("-review")
        }
        #endif
        container = AppStore.container
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
