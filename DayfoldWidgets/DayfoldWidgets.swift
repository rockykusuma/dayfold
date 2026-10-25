import WidgetKit
import SwiftUI
import SwiftData
import DayfoldCore

/// One moment of the Today widget: the day, its open tasks (priority first) and the done count.
struct TodayEntry: TimelineEntry {
    struct Task: Hashable { let text: String; let isPriority: Bool }
    let date: Date
    let open: [Task]
    let done: Int
    let total: Int
    /// False when the store can't be read yet (app not opened since installing the widget).
    var hasData = true

    static let sample = TodayEntry(date: .now, open: [
        Task(text: "Send Q4 hiring plan to leadership", isPriority: true),
        Task(text: "Review Arjun's design doc", isPriority: false),
        Task(text: "Book dentist appointment", isPriority: false),
    ], done: 2, total: 5)
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry { .sample }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(context.isPreview ? .sample : timeline().first ?? .sample)
    }

    /// Now and next midnight (when carry-forward moves the page on), then refresh in 30 minutes for synced changes.
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        completion(Timeline(entries: timeline(), policy: .after(.now.addingTimeInterval(30 * 60))))
    }

    private func timeline() -> [TodayEntry] {
        let now = Date.now
        let midnight = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now))!
        // Read-only and without CloudKit: the app owns syncing; the widget only looks.
        guard let url = SharedStore.groupURL,
              let container = try? ModelContainer(for: Schema(SharedStore.models),
                                                  configurations: ModelConfiguration(url: url, allowsSave: false,
                                                                                     cloudKitDatabase: .none)),
              let entries = try? ModelContext(container).fetch(FetchDescriptor<DayfoldCore.Entry>(sortBy: [SortDescriptor(\.createdAt)]))
        else { return [TodayEntry(date: now, open: [], done: 0, total: 0, hasData: false)] }
        // ponytail: fetches every entry, like the Day page does; add a predicate if stores get large.
        return [now, midnight].map { day in
            let g = DayPage.glance(entries, on: day)
            return TodayEntry(date: day, open: g.open.map { .init(text: $0.text, isPriority: $0.isPriority) },
                              done: g.done, total: g.total)
        }
    }
}

struct TodayWidgetView: View {
    let entry: TodayEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        #if os(iOS)
        case .accessoryCircular:
            Gauge(value: Double(entry.done), in: 0...Double(max(entry.total, 1))) {
                Image(systemName: "checkmark")
            } currentValueLabel: {
                Text(verbatim: "\(entry.open.count)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.open.isEmpty ? "All clear" : "\(entry.open.count) to do").font(.headline)
                ForEach(entry.open.prefix(2), id: \.self) { Text($0.text).lineLimit(1) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        #endif
        case .systemSmall:
            VStack(alignment: .leading, spacing: 4) {
                header
                Spacer(minLength: 0)
                Text(verbatim: "\(entry.open.count)")
                    .font(.system(size: 44, weight: .semibold, design: .serif))
                    .contentTransition(.numericText())
                Text(entry.open.count == 1 ? "task open" : "tasks open").foregroundStyle(.secondary)
                if entry.total > 0 { progress }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    header
                    Spacer()
                    if entry.total > 0 {
                        Text("\(entry.done) of \(entry.total) done").font(.caption).foregroundStyle(.secondary)
                    }
                }
                list
                Spacer(minLength: 0)
            }
        }
    }

    private var header: some View {
        Text(entry.date, format: .dateTime.weekday(.abbreviated).day())
            .font(.system(.subheadline, design: .serif, weight: .semibold))
            .foregroundStyle(.tint)
    }

    private var progress: some View {
        ProgressView(value: Double(entry.done), total: Double(entry.total))
            .accessibilityLabel("\(entry.done) of \(entry.total) done")
    }

    @ViewBuilder
    private var list: some View {
        let limit = family == .systemLarge || family == .systemExtraLarge ? 9 : 3
        if !entry.hasData {
            Text("Open Dayfold once to show today's tasks.").font(.callout).foregroundStyle(.secondary)
        } else if entry.open.isEmpty {
            Text(entry.total == 0 ? "Nothing on today's page." : "All done for today.")
                .font(.system(.callout, design: .serif)).foregroundStyle(.secondary)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.open.prefix(limit), id: \.self) { task in
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Image(systemName: task.isPriority ? "star.fill" : "circle")
                            .font(.caption2)
                            .foregroundStyle(task.isPriority ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        Text(task.text).font(.subheadline).lineLimit(1)
                    }
                }
                if entry.open.count > limit {
                    Text("+\(entry.open.count - limit) more").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Today", provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(Color("WidgetBackground"), for: .widget)
        }
        .configurationDisplayName("Today")
        .description("Today's open tasks, carried forward.")
        .supportedFamilies(families)
    }

    private var families: [WidgetFamily] {
        #if os(iOS)
        [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryRectangular]
        #else
        [.systemSmall, .systemMedium, .systemLarge]
        #endif
    }
}

#Preview(as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry.sample
}
