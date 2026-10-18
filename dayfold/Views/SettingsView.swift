import SwiftUI
import CloudKit
import UserNotifications

/// Review time and days, notification permission, iCloud status.
/// Mac: the app's Settings window (⌘,). iPhone: sheet from the gear button.
struct SettingsView: View {
    @AppStorage(ReviewReminder.hourKey) private var hour = ReviewReminder.defaultHour
    @AppStorage(ReviewReminder.minuteKey) private var minute = ReviewReminder.defaultMinute
    @AppStorage(ReviewReminder.weekdaysKey) private var weekdays = ReviewReminder.defaultWeekdays
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var notifications: UNAuthorizationStatus?
    @State private var iCloud: CKAccountStatus?

    private let calendar = Calendar.current

    var body: some View {
        Form {
            Section {
                DatePicker("Time", selection: time, displayedComponents: .hourAndMinute)
                LabeledContent("Days") {
                    HStack(spacing: 6) {
                        ForEach(orderedWeekdays, id: \.self) { weekday in
                            Toggle(calendar.veryShortWeekdaySymbols[weekday - 1], isOn: dayBinding(weekday))
                                .toggleStyle(.button)
                                .buttonBorderShape(.circle)
                                .accessibilityLabel(calendar.weekdaySymbols[weekday - 1])
                        }
                    }
                    .font(.footnote.weight(.semibold))
                }
            } header: {
                Text("Evening review")
            } footer: {
                Text(weekdays.isEmpty
                     ? "No days selected — the reminder is off. You can still open Review from the toolbar."
                     : "A reminder to fold today's open tasks into tomorrow.")
            }

            Section("Notifications") {
                LabeledContent("Permission") {
                    status(notificationText, ok: notificationsAllowed)
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

    private func dayBinding(_ weekday: Int) -> Binding<Bool> {
        let digit = Character(String(weekday))
        return Binding(
            get: { weekdays.contains(digit) },
            set: { on in
                var set = Set(weekdays)
                if on { set.insert(digit) } else { set.remove(digit) }
                weekdays = String(set.sorted())
            }
        )
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
