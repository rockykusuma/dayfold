import Foundation
import Observation
import UserNotifications

/// The evening nudge. Schedules repeating local notifications and opens Review when one is tapped.
/// Also owns `showReview`, so the toolbar button and a notification tap drive the same sheet.
@Observable
final class ReviewReminder: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReviewReminder()

    var showReview = false

    /// Weekdays use Calendar numbering: 1 = Sunday … 7 = Saturday. Default 18:30 Mon–Fri.
    /// Safe to call repeatedly: it replaces whatever was scheduled before.
    func schedule(hour: Int = 18, minute: Int = 30, weekdays: Set<Int> = [2, 3, 4, 5, 6]) async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

        center.removePendingNotificationRequests(withIdentifiers: (1...7).map { "review.\($0)" })

        let content = UNMutableNotificationContent()
        content.title = "Evening review"
        content.body = "Fold today's open tasks into tomorrow."
        content.sound = .default

        for weekday in weekdays {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: DateComponents(hour: hour, minute: minute, weekday: weekday),
                repeats: true
            )
            try? await center.add(UNNotificationRequest(identifier: "review.\(weekday)", content: content, trigger: trigger))
        }
    }

    // Tapped (cold or warm launch): open Review.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        await MainActor.run { showReview = true }
    }

    // App already in front at 18:30: still show the banner.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
