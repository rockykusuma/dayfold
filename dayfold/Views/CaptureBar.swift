import SwiftUI
import SwiftData
import DayfoldCore

/// The one text field everything goes into. Enter saves. Nothing is required but the text.
struct CaptureBar: View {
    @Environment(\.modelContext) private var context
    let filter: ScopeFilter
    let day: Date
    var focus: FocusState<Bool>.Binding

    @State private var text = ""
    @State private var kind: EntryKind = .task
    @State private var saved = 0
    @AppStorage("capture.lastScope") private var lastScopeRaw = EntryScope.work.rawValue

    private var scope: EntryScope {
        filter.defaultScope ?? (EntryScope(rawValue: lastScopeRaw) ?? .work)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Button {
                    kind = kind == .task ? .note : .task
                } label: {
                    Image(systemName: kind == .task ? "circle" : "minus")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.tint)
                        .contentTransition(.symbolEffect(.replace))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(kind == .task ? "Task" : "Note")
                .accessibilityHint("Switches between task and note")
                .help(kind == .task ? "Task — click for note" : "Note — click for task")

                TextField(kind == .task ? "What did someone ask you for?" : "Write a note…",
                          text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused(focus)
                    .onSubmit(save)

                if filter == .all {
                    Menu {
                        Picker("Scope", selection: $lastScopeRaw) {
                            Label("Work", systemImage: "briefcase").tag(EntryScope.work.rawValue)
                            Label("Personal", systemImage: "house").tag(EntryScope.personal.rawValue)
                        }
                    } label: {
                        Image(systemName: scope == .work ? "briefcase" : "house")
                            .foregroundStyle(.secondary)
                            .frame(width: 28, height: 28)
                    }
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                    .menuIndicator(.hidden)
                    .fixedSize()
                    .accessibilityLabel("Scope: \(scope == .work ? "Work" : "Personal")")
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(.separator, lineWidth: 0.5))

            Button(action: save) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(trimmed.isEmpty ? AnyShapeStyle(.quaternary) : AnyShapeStyle(.tint))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(trimmed.isEmpty)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel("Add")
            .sensoryFeedback(.impact(weight: .light), trigger: saved)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
    }

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func save() {
        guard !trimmed.isEmpty else { return }
        let parsed = CaptureParser.parse(trimmed)
        let entry = Entry(
            text: parsed.text,
            kind: kind,
            scope: parsed.scope ?? scope,
            createdAt: Date(),
            showOn: Calendar.current.isDateInToday(day) ? nil : day,
            dueOn: parsed.dueOn,
            from: parsed.from,
            tags: parsed.tags
        )
        withAnimation(.snappy) { context.insert(entry) }
        text = ""
        saved += 1
    }
}
