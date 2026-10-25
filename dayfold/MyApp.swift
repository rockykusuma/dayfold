import SwiftUI
import SwiftData
import DayfoldCore
import UserNotifications
import WidgetKit

@main
struct DayfoldApp: App {
    let container: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    #if os(macOS)
    @NSApplicationDelegateAdaptor(MacAppDelegate.self) private var appDelegate
    #endif

    init() {
        // Set before launch finishes so a tap that cold-launches the app still opens Review.
        UNUserNotificationCenter.current().delegate = ReviewReminder.shared
        #if DEBUG
        if DemoData.isEnabled {
            ReviewReminder.shared.showReview = CommandLine.arguments.contains("-review")
        }
        #endif
        container = AppStore.container
        // Every save (app, Siri, Mac panel, Services) refreshes the widget; WidgetKit coalesces bursts.
        NotificationCenter.default.addObserver(forName: ModelContext.didSave, object: nil, queue: .main) { _ in
            WidgetCenter.shared.reloadAllTimelines()
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
            // Cover journal content whenever not active (before the app-switcher snapshot); lock only on
            // .background, since the Face ID prompt itself makes the app inactive. Mac: JournalLock watches resign-active.
            JournalLock.shared.appActive(phase == .active)
            if phase == .background { JournalLock.shared.lock() }
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
