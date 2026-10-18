import SwiftUI
import DayfoldCore

/// One line on the page. Bullet-journal marks: ○ task, – note.
struct EntryRow: View {
    let entry: Entry
    let day: Date
    var showScope = true
    let onToggle: () -> Void
    /// Tapping the person's name (e.g. open their page). Nil = plain text.
    var onPerson: ((Person) -> Void)? = nil

    @ScaledMetric(relativeTo: .body) private var markSize: CGFloat = 44
    @Environment(\.dynamicTypeSize) private var typeSize

    private var isTask: Bool { entry.kind == .task }
    private var isClosed: Bool { isTask && !entry.status.isActive }
    private var age: Int { DayPage.age(of: entry, on: day) }
    /// Scheduled after `day` (e.g. next week's repeat, seen from Search): can't be ticked yet.
    private var notYet: Bool { isTask && entry.status.isActive && entry.showOn > Calendar.current.startOfDay(for: day) }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            mark
                .disabled(notYet)
                .opacity(notYet ? 0.4 : 1)

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
        if entry.isWaiting {
            Button(action: onToggle) {
                Image(systemName: "arrow.forward.circle")
                    .font(.title3)
                    .foregroundStyle(.orange)
                    .frame(width: markSize, height: markSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Got it — mark delivered")
        } else if isTask {
            Button(action: onToggle) {
                Image(systemName: statusSymbol)
                    .font(.title3)
                    .foregroundStyle(isClosed ? AnyShapeStyle(.secondary) : AnyShapeStyle(.tint))
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: markSize, height: markSize)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.success, trigger: entry.status) { _, new in new == .done }
            .accessibilityLabel(entry.status.isActive ? "Mark done" : "Reopen")
        } else {
            Image(systemName: "minus")
                .font(.body.weight(.semibold))
                .foregroundStyle(.tertiary)
                .frame(width: markSize, height: markSize)
                .accessibilityLabel("Note")
        }
    }

    private var meta: some View {
        // Wraps into a column at accessibility sizes instead of truncating.
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
                                                  : AnyLayout(HStackLayout(spacing: 6))
        return layout {
            Text(entry.createdAt, format: .dateTime.hour().minute())
                .monospacedDigit()
            if showScope {
                Image(systemName: entry.scope == .work ? "briefcase" : "house")
                    .accessibilityLabel(entry.scope == .work ? "Work" : "Personal")
            }
            if entry.isPriority {
                Image(systemName: "star.fill")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Priority")
            }
            if let rule = entry.repeatRule {
                Image(systemName: "repeat")
                    .accessibilityLabel(rule.summary)
            }
            if let person = entry.person, let link = entry.link {
                personName(person, waiting: link == .to)
            } else if let from = entry.from, !from.isEmpty {
                Text("· \(from)")
            }
            if let due = entry.dueOn {
                Text("· \(Image(systemName: "calendar")) \(due.formatted(.dateTime.day().month(.abbreviated)))")
            }
            if let p = entry.checklistProgress {
                Text("\(Image(systemName: "checklist")) \(p.done)/\(p.total)")
                    .accessibilityLabel("\(p.done) of \(p.total) checklist items done")
            }
            let tags = Tags.display(entry.tags)
            ForEach(tags.prefix(2), id: \.self) { tag in
                Button { SearchRouter.shared.show("#\(tag)") } label: { Text("#\(tag)") }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Tag \(tag)")
                    .accessibilityHint("Searches this tag")
            }
            if tags.count > 2 {
                Text("+\(tags.count - 2)")
                    .accessibilityLabel("\(tags.count - 2) more tags")
            }
            if isTask && entry.status == .inProgress {
                Text("· in progress")
            }
            if notYet {
                Text("from \(entry.showOn.formatted(.dateTime.weekday(.abbreviated).day()))")
                    .accessibilityLabel("Starts \(entry.showOn.formatted(.dateTime.weekday(.wide).day().month(.wide)))")
            }
            if isTask && entry.status.isActive {
                let days = entry.isWaiting ? Review.waitingDays(entry, on: day) : age
                if days > 0 { AgeBadge(days: days) }
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func personName(_ person: Person, waiting: Bool) -> some View {
        let label = Text(waiting ? "· ⇢ \(person.name)" : "· \(person.name)")
        if let onPerson {
            Button { onPerson(person) } label: { label.underline() }
                .buttonStyle(.plain)
                .accessibilityHint("Opens \(person.name)")
        } else {
            label
        }
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
