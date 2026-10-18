import SwiftUI
import DayfoldCore

/// One line on the page. Bullet-journal marks: ○ task, – note.
struct EntryRow: View {
    let entry: Entry
    let day: Date
    var showScope = true
    let onToggle: () -> Void

    private var isTask: Bool { entry.kind == .task }
    private var isClosed: Bool { isTask && !entry.status.isActive }
    private var age: Int { DayPage.age(of: entry, on: day) }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            mark

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.text)
                    .strikethrough(isClosed, color: .secondary)
                    .foregroundStyle(isClosed ? .secondary : .primary)
                    .fixedSize(horizontal: false, vertical: true)

                meta
            }
            .padding(.vertical, 11)
        }
        .animation(.snappy(duration: 0.25), value: entry.status)
    }

    @ViewBuilder
    private var mark: some View {
        if isTask {
            Button(action: onToggle) {
                Image(systemName: statusSymbol)
                    .font(.title3)
                    .foregroundStyle(isClosed ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: entry.status) { _, new in new == .done }
            .accessibilityLabel(entry.status.isActive ? "Mark done" : "Reopen")
        } else {
            Image(systemName: "minus")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
                .frame(width: 44, height: 44)
                .accessibilityLabel("Note")
        }
    }

    private var meta: some View {
        HStack(spacing: 6) {
            Text(entry.createdAt, format: .dateTime.hour().minute())
                .monospacedDigit()
            if showScope {
                Image(systemName: entry.scope == .work ? "briefcase" : "house")
                    .accessibilityLabel(entry.scope == .work ? "Work" : "Personal")
            }
            if let from = entry.from, !from.isEmpty {
                Text("· \(from)")
            }
            if let due = entry.dueOn {
                Text("· \(Image(systemName: "calendar")) \(due.formatted(.dateTime.day().month(.abbreviated)))")
            }
            if isTask && entry.status == .inProgress {
                Text("· in progress")
            }
            if isTask && entry.status.isActive && age > 0 {
                AgeBadge(days: age)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var statusSymbol: String {
        switch entry.status {
        case .open: "circle"
        case .inProgress: "circle.lefthalf.filled"
        case .done: "checkmark.circle.fill"
        case .dropped: "xmark.circle"
        }
    }
}

/// "4d" pill. Turns amber at 3+ days so stale asks stand out.
struct AgeBadge: View {
    let days: Int
    private var stale: Bool { days >= 3 }

    var body: some View {
        Text("\(days)d")
            .font(.caption2.weight(.semibold).monospacedDigit())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(stale ? Color.orange : .secondary)
            .background(stale ? Color.orange.opacity(0.15) : Color.secondary.opacity(0.12), in: Capsule())
            .accessibilityLabel("\(days) days old")
    }
}
