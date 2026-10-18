import SwiftUI
import DayfoldCore

/// Evening Review: one card per active task, four choices each.
/// The queue is snapshotted on open so "Still going" cards don't come back around.
struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var queue: [Entry]
    @State private var index = 0
    @State private var tally: [String: Int] = [:]
    @State private var pickingDate = false
    @State private var delegating = false
    @State private var pushDate: Date

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    private var tomorrow: Date { calendar.date(byAdding: .day, value: 1, to: today)! }
    private var nextMonday: Date {
        calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) ?? tomorrow
    }
    private var finished: Bool { index >= queue.count }

    /// Side by side normally; stacked at accessibility text sizes so nothing truncates.
    private var pairLayout: AnyLayout {
        typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
                                     : AnyLayout(HStackLayout(spacing: 12))
    }

    init(entries: [Entry]) {
        _queue = State(initialValue: entries)
        _pushDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 1,
                                                                to: Calendar.current.startOfDay(for: Date()))!)
    }

    var body: some View {
        NavigationStack {
            Group {
                if finished {
                    summary.padding(20)
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            progress
                            if queue[index].isWaiting {
                                Label("Waiting on others · \(queue.dropFirst(index).filter(\.isWaiting).count)",
                                      systemImage: "arrow.forward.circle")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.orange)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            ZStack {
                                card(queue[index])
                                    .id(queue[index].id)
                                    .transition(reduceMotion
                                        ? .opacity
                                        : .asymmetric(insertion: .opacity,
                                                      removal: .offset(x: -420).combined(with: .opacity)))
                            }
                            .padding(.bottom, 28) // room for the cards peeking behind
                        }
                        .padding(20)
                        .readableWidth()
                    }
                    .safeAreaInset(edge: .bottom) {
                        actions
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .readableWidth()
                            .background(Color.paper)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.paper)
            .frame(minWidth: 380, minHeight: 520)
            .navigationTitle("Review")
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(finished ? "Close" : "Later") { dismiss() }
                }
            }
            .sheet(isPresented: $pickingDate) { datePickerSheet }
            .sheet(isPresented: $delegating) {
                PeoplePicker(title: "Delegate to") { person in
                    guard !finished else { return }
                    withAnimation(reduceMotion ? .default : .snappy(duration: 0.3)) {
                        Review.delegate(queue[index], to: person)
                        tally["delegated", default: 0] += 1
                        index += 1
                    }
                }
            }
            .sensoryFeedback(.impact(weight: .light), trigger: index)
        }
    }

    // MARK: Pieces

    private var progress: some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(index), total: Double(max(queue.count, 1)))
                .tint(.accentColor)
            Text("\(index + 1) of \(queue.count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
        .accessibilityElement(children: .combine)
    }

    private func card(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                pairLayout {
                    if entry.isWaiting, let person = entry.person {
                        Label("Waiting on \(person.name)", systemImage: "arrow.forward.circle")
                            .foregroundStyle(.orange)
                        if let team = person.team { Text(team) }
                    } else {
                        Label(entry.scope == .work ? "Work" : "Personal",
                              systemImage: entry.scope == .work ? "briefcase" : "house")
                        if let from = entry.person?.name ?? entry.from, !from.isEmpty { Text("from \(from)") }
                    }
                }
                Spacer(minLength: 8)
                let days = entry.isWaiting ? Review.waitingDays(entry, on: today) : DayPage.age(of: entry, on: today)
                if days > 0 { AgeBadge(days: days) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(entry.text)
                .font(.system(.title2, design: .serif, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            pairLayout {
                Label(entry.createdAt.formatted(.dateTime.weekday(.abbreviated).hour().minute()), systemImage: "clock")
                if entry.status == .inProgress { Label("In progress", systemImage: "circle.lefthalf.filled") }
                if let due = entry.dueOn {
                    Label(due.formatted(.dateTime.day().month(.abbreviated)), systemImage: "calendar")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 240, alignment: .topLeading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.separator, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        .background(alignment: .bottom) { backCards }
    }

    /// Edges of the next cards, sized to the front card so they always line up.
    private var backCards: some View {
        let behind = min(2, queue.count - index - 1)
        return ZStack {
            ForEach(Array((1...max(behind, 1)).reversed()), id: \.self) { depth in
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.card)
                    .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.separator, lineWidth: 0.5))
                    .scaleEffect(1 - CGFloat(depth) * 0.05, anchor: .bottom)
                    .offset(y: CGFloat(depth) * 14)
                    .opacity(behind > 0 ? 1 - CGFloat(depth) * 0.3 : 0)
            }
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var actions: some View {
        if !finished, queue[index].isWaiting {
            waitingActions(queue[index])
        } else {
            ownActions
        }
    }

    private var ownActions: some View {
        VStack(spacing: 12) {
            Button { decide(.done, "done") } label: {
                Label("Done", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 32)
                    .foregroundStyle(Color.paper) // readable on ink in both modes
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            pairLayout {
                Button { decide(.stillGoing, "still going") } label: {
                    Label("Still going", systemImage: "circle.lefthalf.filled").frame(maxWidth: .infinity, minHeight: 32)
                }
                laterMenu("Push to…", delegate: true)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) { decide(.drop, "dropped") } label: {
                Text("Drop").frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.delete, modifiers: .command)
        }
        .controlSize(.large)
    }

    private func waitingActions(_ entry: Entry) -> some View {
        VStack(spacing: 12) {
            Button { decide(.done, "got it") } label: {
                Label("Got it", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 32)
                    .foregroundStyle(Color.paper)
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            pairLayout {
                Button { decide(.nudged, "nudged") } label: {
                    Label("Nudged today", systemImage: "bell").frame(maxWidth: .infinity, minHeight: 32)
                }
                laterMenu("Follow up on…", delegate: false)
            }
            .buttonStyle(.bordered)

            pairLayout {
                ShareLink(item: followUpMessage(entry)) {
                    Label("Message…", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity, minHeight: 44)
                }
                Button(role: .destructive) { decide(.drop, "dropped") } label: {
                    Text("Drop").frame(maxWidth: .infinity, minHeight: 44)
                }
                .keyboardShortcut(.delete, modifiers: .command)
            }
            .buttonStyle(.borderless)
        }
        .controlSize(.large)
    }

    private func laterMenu(_ title: String, delegate: Bool) -> some View {
        Menu {
            Button("Tomorrow") { decide(.push(to: tomorrow), "pushed") }
            Button("Next Monday") { decide(.push(to: nextMonday), "pushed") }
            Divider()
            Button("Pick a date…") { pickingDate = true }
            if delegate {
                Divider()
                Button("Delegate to…") { delegating = true }
            }
        } label: {
            Label(title, systemImage: "arrow.turn.down.right").frame(maxWidth: .infinity, minHeight: 32)
        }
        .menuIndicator(.hidden)
    }

    private func followUpMessage(_ entry: Entry) -> String {
        let first = entry.person?.name.split(separator: " ").first.map(String.init) ?? "there"
        return "Hi \(first), checking in on: \(entry.text)"
    }

    private var summary: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .symbolEffect(.bounce, value: finished)
            Text(queue.isEmpty ? "Nothing to review" : "All folded")
                .font(.system(.title, design: .serif, weight: .semibold))
            Text(queue.isEmpty ? "No open tasks today." : "Tomorrow's page is ready.")
                .foregroundStyle(.secondary)
            if !tally.isEmpty {
                Text(["done", "got it", "still going", "pushed", "delegated", "nudged", "dropped"]
                    .compactMap { key in tally[key].map { "\($0) \(key)" } }
                    .joined(separator: " · "))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            Button { dismiss() } label: { Text("Close").foregroundStyle(Color.paper) }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 12)
                .keyboardShortcut(.defaultAction)
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
    }

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker("Push to", selection: $pushDate, in: tomorrow..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()
                .navigationTitle("Push to")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { pickingDate = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Push") {
                            pickingDate = false
                            decide(.push(to: pushDate), "pushed")
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }

    private func decide(_ action: ReviewAction, _ label: String) {
        guard !finished else { return }
        withAnimation(reduceMotion ? .default : .snappy(duration: 0.3)) {
            Review.apply(action, to: queue[index])
            tally[label, default: 0] += 1
            index += 1
        }
    }
}

private extension View {
    /// Comfortable column on iPad / Mac windows; full width on phones.
    func readableWidth() -> some View {
        frame(maxWidth: 520).frame(maxWidth: .infinity)
    }
}
