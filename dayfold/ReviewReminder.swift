import Foundation
import Observation
import UserNotifications

/// The evening nudge. Schedules repeating local notifications and opens Review when one is tapped.
/// Also owns `showReview`, so the toolbar button and a notification tap drive the same sheet.
@Observable
final class ReviewReminder: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ReviewReminder()

    var showReview = false

    // Settings storage. Weekdays use Calendar numbering (1 = Sunday … 7 = Saturday) as a digit string.
    static let hourKey = "review.hour", minuteKey = "review.minute", weekdaysKey = "review.weekdays"
    static let defaultHour = 18, defaultMinute = 30, defaultWeekdays = "23456"

    /// Schedules from the stored settings (default 18:30 Mon–Fri). No weekdays = no reminder.
    /// Safe to call repeatedly: it replaces whatever was scheduled before.
    /// Only `ask` shows the permission prompt (Settings, Review's offer); otherwise it schedules only if already allowed.
    func schedule(ask: Bool = false) async {
        let defaults = UserDefaults.standard
        let hour = defaults.object(forKey: Self.hourKey) as? Int ?? Self.defaultHour
        let minute = defaults.object(forKey: Self.minuteKey) as? Int ?? Self.defaultMinute
        let weekdays = Set((defaults.string(forKey: Self.weekdaysKey) ?? Self.defaultWeekdays).compactMap { Int(String($0)) })

        let center = UNUserNotificationCenter.current()
        if ask {
            guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }
        } else {
            guard [.authorized, .provisional].contains(await center.notificationSettings().authorizationStatus) else { return }
        }

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

    /// The stored time, for "Remind me at 6:30 PM".
    static var timeText: String {
        let defaults = UserDefaults.standard
        let c = DateComponents(hour: defaults.object(forKey: hourKey) as? Int ?? defaultHour,
                               minute: defaults.object(forKey: minuteKey) as? Int ?? defaultMinute)
        return Calendar.current.date(from: c)?.formatted(date: .omitted, time: .shortened) ?? ""
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
