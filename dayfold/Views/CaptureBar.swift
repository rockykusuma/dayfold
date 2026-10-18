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
    @AppStorage("capture.lastScope") private var lastScopeRaw = EntryScope.work.rawValue

    private var scope: EntryScope {
        filter.defaultScope ?? (EntryScope(rawValue: lastScopeRaw) ?? .work)
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Picker("", selection: $kind) {
                    Image(systemName: "circle").tag(EntryKind.task)
                    Image(systemName: "text.alignleft").tag(EntryKind.note)
                }
                .pickerStyle(.segmented)
                .frame(width: 90)
                .help("Task or note")

                TextField(kind == .task ? "What did someone ask you for?" : "Write a note…", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .focused(focus)
                    .onSubmit(save)

                Button(action: save) {
                    Image(systemName: "arrow.up.circle.fill").font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(trimmed.isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }

            if filter == .all {
                Picker("Scope", selection: $lastScopeRaw) {
                    Text("Work").tag(EntryScope.work.rawValue)
                    Text("Personal").tag(EntryScope.personal.rawValue)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
                .font(.caption)
            }
        }
        .padding(12)
        .background(.bar)
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
        context.insert(entry)
        text = ""
    }
}
