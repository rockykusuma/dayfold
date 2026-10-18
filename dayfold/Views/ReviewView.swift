import SwiftUI
import DayfoldCore

/// Evening Review: one card per active task, four choices each.
/// The queue is snapshotted on open so "Still going" cards don't come back around.
struct ReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var queue: [Entry]
    @State private var index = 0
    @State private var pickingDate = false
    @State private var pushDate: Date

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())
    private var tomorrow: Date { calendar.date(byAdding: .day, value: 1, to: today)! }
    private var nextMonday: Date {
        calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime) ?? tomorrow
    }

    init(entries: [Entry]) {
        _queue = State(initialValue: entries)
        _pushDate = State(initialValue: Calendar.current.date(byAdding: .day, value: 1,
                                                                to: Calendar.current.startOfDay(for: Date()))!)
    }

    var body: some View {
        NavigationStack {
            Group {
                if index < queue.count {
                    card(queue[index])
                } else {
                    ContentUnavailableView("All folded",
                                           systemImage: "checkmark.circle",
                                           description: Text("Tomorrow's page is ready."))
                }
            }
            .padding()
            .frame(minWidth: 360, minHeight: 360)
            .navigationTitle("Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(index < queue.count ? "Later" : "Close") { dismiss() }
                }
            }
            .sheet(isPresented: $pickingDate) { datePickerSheet }
        }
    }

    private func card(_ entry: Entry) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text("\(index + 1) of \(queue.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                ProgressView(value: Double(index), total: Double(queue.count))
            }

            Spacer()

            VStack(spacing: 8) {
                Text(entry.text)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                HStack(spacing: 8) {
                    if let from = entry.from, !from.isEmpty { Text("from \(from)") }
                    let age = DayPage.age(of: entry, on: today)
                    if age > 0 { Text("\(age)d old") }
                    if entry.status == .inProgress { Text("in progress") }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .id(entry.id)
            .transition(.push(from: .trailing))

            Spacer()

            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    Button { decide(.done) } label: { Label("Done", systemImage: "checkmark").frame(maxWidth: .infinity) }
                        .tint(.green)
                    Button { decide(.stillGoing) } label: {
                        Label("Still going", systemImage: "circle.lefthalf.filled").frame(maxWidth: .infinity)
                    }
                }
                GridRow {
                    Menu {
                        Button("Tomorrow") { decide(.push(to: tomorrow)) }
                        Button("Next Monday") { decide(.push(to: nextMonday)) }
                        Button("Pick a date…") { pickingDate = true }
                    } label: {
                        Label("Push to…", systemImage: "arrow.turn.down.right").frame(maxWidth: .infinity)
                    }
                    Button(role: .destructive) { decide(.drop) } label: {
                        Label("Drop", systemImage: "xmark").frame(maxWidth: .infinity)
                    }
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private var datePickerSheet: some View {
        NavigationStack {
            DatePicker("Push to", selection: $pushDate, in: tomorrow..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .navigationTitle("Push to")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { pickingDate = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Push") {
                            pickingDate = false
                            decide(.push(to: pushDate))
                        }
                    }
                }
        }
    }

    private func decide(_ action: ReviewAction) {
        guard index < queue.count else { return }
        withAnimation {
            Review.apply(action, to: queue[index])
            index += 1
        }
    }
}
