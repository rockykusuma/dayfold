import SwiftUI
import DayfoldCore

/// Month calendar (written-day dots, busy-day shading), two counts, and the way into the Week page.
/// Rules live in `JournalInsights`; this view only draws them.
struct InsightsCard: View {
    let entries: [JournalEntry]
    let tasks: [Entry]
    /// Called with a day that has entries.
    let onSelectDay: (Date) -> Void
    let onWeek: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Months back from now (0 = this month).
    @State private var monthOffset = 0

    private let calendar = Calendar.current
    private static let shade: [Double] = [0, 0.12, 0.24, 0.4]
    private var anchor: Date { calendar.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date() }
    private var motion: Animation? { reduceMotion ? nil : .snappy }

    /// `veryShortWeekdaySymbols` starts on Sunday; rotate to the user's first weekday.
    private var weekdays: [String] {
        let s = calendar.veryShortWeekdaySymbols
        let f = calendar.firstWeekday - 1
        return Array(s[f...] + s[..<f])
    }

    var body: some View {
        let insights = JournalInsights(entries: entries, tasks: tasks, containing: anchor, today: Date())
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text(insights.month.start, format: .dateTime.month(.wide).year())
                    .font(.system(.title2, design: .serif, weight: .semibold))
                    .contentTransition(.numericText())
                Spacer(minLength: 8)
                monthButton(-1, symbol: "chevron.left", label: "Previous month")
                monthButton(1, symbol: "chevron.right", label: "Next month")
                    .disabled(monthOffset == 0)
            }
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)

            grid(insights)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1) // 7 columns can't grow further

            Text(counts(insights))
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)

            Divider()

            Button(action: onWeek) {
                HStack {
                    Text("This week")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func grid(_ insights: JournalInsights) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
        let cells = Array(insights.weeks.joined().enumerated())
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(Array(weekdays.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            ForEach(cells, id: \.offset) { _, day in
                if let day { cell(day) } else { Color.clear.frame(height: 1).accessibilityHidden(true) }
            }
        }
    }

    @ViewBuilder
    private func cell(_ day: CalendarDay) -> some View {
        let face = VStack(spacing: 2) {
            Text("\(day.day)")
                .font(.subheadline.monospacedDigit())
                .frame(width: 36, height: 36)
                .background(Circle().fill(Color.accentColor.opacity(Self.shade[JournalInsights.level(for: day.doneCount)])))
                .overlay { if day.isToday { Circle().strokeBorder(.tint, lineWidth: 1.5) } }
            Circle()
                .fill(.tint)
                .frame(width: 5, height: 5)
                .opacity(day.hasEntry ? 1 : 0)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .opacity(day.isFuture ? 0.35 : 1)
        .contentShape(Rectangle())
        if day.hasEntry {
            Button { onSelectDay(day.date) } label: { face }
                .buttonStyle(.plain)
                .accessibilityLabel(label(day))
        } else {
            face
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label(day))
        }
    }

    /// "Thursday 22 October, 3 done, has entries"
    private func label(_ day: CalendarDay) -> String {
        [day.date.formatted(.dateTime.weekday(.wide).day().month(.wide)),
         day.doneCount > 0 ? "\(day.doneCount) done" : nil,
         day.hasEntry ? "has entries" : nil]
            .compactMap { $0 }
            .joined(separator: ", ")
    }

    private func counts(_ insights: JournalInsights) -> String {
        let e = insights.entriesThisYear, d = insights.daysWrittenThisMonth
        return "\(e) \(e == 1 ? "entry" : "entries") this year · \(d) \(d == 1 ? "day" : "days") written this month"
    }

    private func monthButton(_ direction: Int, symbol: String, label: String) -> some View {
        Button {
            withAnimation(motion) { monthOffset += direction }
        } label: {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .accessibilityLabel(label)
    }
}
