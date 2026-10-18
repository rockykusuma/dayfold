import SwiftUI
import CloudKit
import UserNotifications

/// Review time and days, notification permission, iCloud status.
/// Mac: the app's Settings window (⌘,). iPhone: sheet from the gear button.
struct SettingsView: View {
    @AppStorage(ReviewReminder.hourKey) private var hour = ReviewReminder.defaultHour
    @AppStorage(ReviewReminder.minuteKey) private var minute = ReviewReminder.defaultMinute
    @AppStorage(ReviewReminder.weekdaysKey) private var weekdays = ReviewReminder.defaultWeekdays
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var notifications: UNAuthorizationStatus?
    @State private var iCloud: CKAccountStatus?
    @ScaledMetric(relativeTo: .subheadline) private var dayCircle: CGFloat = 38

    private let calendar = Calendar.current

    var body: some View {
        Form {
            Section {
                DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Days")
                    HStack(spacing: 2) {
                        ForEach(orderedWeekdays, id: \.self) { dayButton($0) }
                    }
                }
                Stepper(value: $nudgeAfter, in: 1...14) {
                    LabeledContent("Nudge after", value: nudgeAfter == 1 ? "1 day" : "\(nudgeAfter) days")
                }
            } header: {
                Text("Evening review")
            } footer: {
                Text(weekdays.isEmpty
                     ? "No days selected — the reminder is off. You can still open Review from the toolbar."
                     : "A reminder to fold today's open tasks into tomorrow. Things you're waiting on join Review once they've waited this long.")
            }

            Section("Notifications") {
                LabeledContent("Permission") {
                    status(notificationText, ok: notificationsAllowed)
                }
                if notifications == .notDetermined {
                    Button("Turn On Notifications") {
                        Task {
                            await ReviewReminder.shared.schedule() // asks for permission, then schedules
                            await refresh()
                        }
                    }
                }
                if notifications == .denied {
                    Button("Open System Settings") { openURL(systemSettingsURL) }
                }
            }

            Section {
                LabeledContent("iCloud") {
                    status(iCloudText, ok: iCloud == .available)
                }
            } header: {
                Text("Sync")
            } footer: {
                Text("Entries sync through your private iCloud database. Nothing leaves your account.")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color.paper)
        .task { await refresh() }
        .onChange(of: "\(hour):\(minute):\(weekdays)") {
            Task {
                await ReviewReminder.shared.schedule()
                await refresh()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { Task { await refresh() } }
        }
        #if os(macOS)
        .frame(width: 460)
        .fixedSize(horizontal: false, vertical: true)
        #endif
    }

    // MARK: Bindings

    private var time: Binding<Date> {
        Binding(
            get: { calendar.date(from: DateComponents(hour: hour, minute: minute)) ?? Date() },
            set: {
                let c = calendar.dateComponents([.hour, .minute], from: $0)
                hour = c.hour ?? ReviewReminder.defaultHour
                minute = c.minute ?? ReviewReminder.defaultMinute
            }
        )
    }

    /// Filled ink circle = on. Full-width hit area per day, at least 44pt tall.
    private func dayButton(_ weekday: Int) -> some View {
        let digit = Character(String(weekday))
        let on = weekdays.contains(digit)
        return Button {
            var set = Set(weekdays)
            if on { set.remove(digit) } else { set.insert(digit) }
            weekdays = String(set.sorted())
        } label: {
            Text(calendar.veryShortWeekdaySymbols[weekday - 1])
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(on ? Color.paper : Color.primary)
                .frame(width: dayCircle, height: dayCircle)
                .background(Circle().fill(on ? Color.accentColor : Color.secondary.opacity(0.12)))
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.snappy(duration: 0.2), value: on)
        .accessibilityLabel(calendar.weekdaySymbols[weekday - 1])
        .accessibilityAddTraits(on ? .isSelected : [])
    }

    /// Weekday numbers starting from the locale's first day of the week.
    private var orderedWeekdays: [Int] {
        (0..<7).map { (calendar.firstWeekday - 1 + $0) % 7 + 1 }
    }

    // MARK: Status

    private func status(_ text: String, ok: Bool) -> some View {
        Label(text, systemImage: ok ? "checkmark.circle.fill" : "exclamationmark.circle")
            .foregroundStyle(ok ? Color.green : .orange)
            .labelStyle(.titleAndIcon)
    }

    private var notificationsAllowed: Bool {
        guard let notifications else { return false }
        return notifications != .denied && notifications != .notDetermined
    }

    private var notificationText: String {
        switch notifications {
        case nil: "Checking…"
        case .denied: "Off"
        case .notDetermined: "Not asked yet"
        default: "Allowed"
        }
    }

    private var iCloudText: String {
        switch iCloud {
        case nil: "Checking…"
        case .available: "Syncing"
        case .noAccount: "Not signed in"
        case .restricted: "Restricted"
        case .temporarilyUnavailable: "Temporarily unavailable"
        default: "Unknown"
        }
    }

    private var systemSettingsURL: URL {
        #if os(iOS)
        URL(string: UIApplication.openSettingsURLString)!
        #else
        URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!
        #endif
    }

    private func refresh() async {
        notifications = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        iCloud = try? await CKContainer(identifier: "iCloud.com.rockykusuma.dayfold").accountStatus()
    }
}

#Preview {
    SettingsView()
}
