import SwiftUI
import DayfoldCore

struct EntryRow: View {
    let entry: Entry
    let day: Date
    let onToggle: () -> Void

    private var isTask: Bool { entry.kind == .task }
    private var age: Int { DayPage.age(of: entry, on: day) }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(entry.createdAt, format: .dateTime.hour().minute())
                .font(.caption.monospacedDigit())
                .foregroundStyle(.tertiary)
                .frame(width: 48, alignment: .leading)

            if isTask {
                Button(action: onToggle) {
                    Image(systemName: statusSymbol)
                        .foregroundStyle(entry.status.isActive ? Color.secondary : .green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(entry.status.isActive ? "Mark done" : "Reopen")
            } else {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.text)
                    .strikethrough(isTask && !entry.status.isActive)
                    .foregroundStyle(isTask && !entry.status.isActive ? .secondary : .primary)

                HStack(spacing: 8) {
                    Label(entry.scope == .work ? "Work" : "Personal",
                          systemImage: entry.scope == .work ? "briefcase" : "house")
                    if let from = entry.from, !from.isEmpty {
                        Text("from \(from)")
                    }
                    if isTask && entry.status == .inProgress {
                        Text("in progress")
                    }
                    if isTask && entry.status.isActive && age > 0 {
                        Text("\(age)d")
                            .fontWeight(.semibold)
                            .foregroundStyle(age >= 3 ? .orange : .secondary)
                    }
                    if let due = entry.dueOn {
                        Label(due.formatted(.dateTime.day().month(.abbreviated)), systemImage: "calendar")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .labelStyle(.titleAndIcon)
            }
        }
        .padding(.vertical, 2)
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
