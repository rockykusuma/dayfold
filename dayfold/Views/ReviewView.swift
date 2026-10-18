import SwiftUI
import DayfoldCore

/// Evening Review: one card per active task, four choices each.
/// The queue is snapshotted on open so "Still going" cards don't come back around.
struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var queue: [Entry]
    @State private var index = 0
    @State private var tally: [String: Int] = [:]
    @State private var pickingDate = false
    @State private var pushDate: Date

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    private var tomorrow: Date { calendar.date(byAdding: .day, value: 1, to: today)! }
    private var nextMonday: Date {
        calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) ?? tomorrow
    }
    private var finished: Bool { index >= queue.count }

    init(entries: [Entry]) {
        _queue = State(initialValue: entries)
        _pushDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 1,
                                                                to: Calendar.current.startOfDay(for: Date()))!)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if finished {
                    summary
                } else {
                    progress
                    stack
                    actions
                }
            }
            .padding(20)
            .frame(maxWidth: 520, maxHeight: .infinity)
            .frame(maxWidth: .infinity)
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

    /// Current card on top, up to two peeking behind it.
    private var stack: some View {
        ZStack {
            ForEach(Array(queue.enumerated()).filter { $0.offset >= index && $0.offset < index + 3 }.reversed(), id: \.element.id) { offset, entry in
                let depth = offset - index
                card(entry)
                    .overlay { // back cards show only their edge, not their text
                        if depth > 0 { RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.card).padding(1) }
                    }
                    .scaleEffect(1 - CGFloat(depth) * 0.05, anchor: .bottom)
                    .offset(y: CGFloat(depth) * 14)
                    .opacity(depth == 0 ? 1 : 0.6)
                    .allowsHitTesting(depth == 0)
                    .accessibilityHidden(depth != 0)
                    .transition(reduceMotion
                        ? .opacity
                        : .asymmetric(insertion: .opacity,
                                      removal: .offset(x: -420).combined(with: .opacity)))
            }
        }
        .frame(maxHeight: .infinity)
    }

    private func card(_ entry: Entry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: entry.scope == .work ? "briefcase" : "house")
                Text(entry.scope == .work ? "Work" : "Personal")
                if let from = entry.from, !from.isEmpty { Text("· from \(from)") }
                Spacer()
                let age = DayPage.age(of: entry, on: today)
                if age > 0 { AgeBadge(days: age) }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(entry.text)
                .font(.system(.title2, design: .serif, weight: .medium))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            HStack(spacing: 12) {
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
        .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 320, alignment: .topLeading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(.separator, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button { decide(.done, "done") } label: {
                Label("Done", systemImage: "checkmark").frame(maxWidth: .infinity, minHeight: 32)
                    .foregroundStyle(Color.paper) // readable on ink in both modes
            }
            .buttonStyle(.borderedProminent)
            .keyboardShortcut(.defaultAction)

            HStack(spacing: 12) {
                Button { decide(.stillGoing, "still going") } label: {
                    Label("Still going", systemImage: "circle.lefthalf.filled").frame(maxWidth: .infinity, minHeight: 32)
                }
                Menu {
                    Button("Tomorrow") { decide(.push(to: tomorrow), "pushed") }
                    Button("Next Monday") { decide(.push(to: nextMonday), "pushed") }
                    Divider()
                    Button("Pick a date…") { pickingDate = true }
                } label: {
                    Label("Push to…", systemImage: "arrow.turn.down.right").frame(maxWidth: .infinity, minHeight: 32)
                }
                .menuIndicator(.hidden)
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
                Text(["done", "still going", "pushed", "dropped"]
                    .compactMap { key in tally[key].map { "\($0) \(key)" } }
                    .joined(separator: " · "))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
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
