import SwiftUI
import SwiftData
import DayfoldCore

/// The one text field everything goes into. Enter saves. Nothing is required but the text.
struct CaptureBar: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Person.name) private var people: [Person]
    let filter: ScopeFilter
    let day: Date
    var focus: FocusState<Bool>.Binding
    /// Set on a person page: every capture links to this person this way.
    var linkedTo: (person: Person, link: PersonLink)? = nil

    @State private var text = ""
    @State private var kind: EntryKind = .task
    @State private var saved = 0
    @ScaledMetric(relativeTo: .body) private var iconBox: CGFloat = 28
    @AppStorage("capture.lastScope") private var lastScopeRaw = EntryScope.work.rawValue

    private var scope: EntryScope {
        filter.defaultScope ?? (EntryScope(rawValue: lastScopeRaw) ?? .work)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !suggestions.isEmpty { suggestionStrip }
            HStack(alignment: .bottom, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    if linkedTo == nil {
                        Button {
                            kind = kind == .task ? .note : .task
                        } label: {
                            Image(systemName: kind == .task ? "circle" : "minus")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.tint)
                                .contentTransition(.symbolEffect(.replace))
                                .frame(width: iconBox, height: iconBox)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(kind == .task ? "Task" : "Note")
                        .accessibilityHint("Switches between task and note")
                        .help(kind == .task ? "Task — click for note" : "Note — click for task")
                    }

                    TextField(placeholder, text: $text, axis: .vertical)
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
                                .frame(width: iconBox, height: iconBox)
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
        .overlay(alignment: .top) { Divider() }
        .dynamicTypeSize(...DynamicTypeSize.accessibility2) // keep room for the page above
    }

    private var placeholder: String {
        guard let linkedTo else { return kind == .task ? "What did someone ask you for?" : "Write a note…" }
        let first = linkedTo.person.name.split(separator: " ").first.map(String.init) ?? linkedTo.person.name
        switch linkedTo.link {
        case .from: return "Something you owe \(first)…"
        case .to: return "Waiting on \(first) for…"
        case .about: return "Note about \(first)…"
        }
    }

    /// People matching a trailing from:/to: token, most recently used first.
    private var suggestions: [Person] {
        guard linkedTo == nil, let token = PeopleDirectory.completionToken(in: text) else { return [] }
        let recent = people.sorted { lastUsed($0) > lastUsed($1) }
        return PeopleDirectory.completions(for: token.partial, in: recent.map(\.name)).map { recent[$0] }
    }

    private func lastUsed(_ person: Person) -> Date {
        (person.entries ?? []).map(\.createdAt).max() ?? person.createdAt
    }

    private var suggestionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(suggestions) { person in
                    Button { complete(with: person) } label: {
                        Text(person.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .frame(minHeight: 32)
                            .background(Color.card, in: Capsule())
                            .overlay(Capsule().strokeBorder(.separator, lineWidth: 0.5))
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .transition(.opacity)
    }

    private func complete(with person: Person) {
        guard let token = PeopleDirectory.completionToken(in: text) else { return }
        text = String(text.dropLast(token.keyword.count + token.partial.count))
            + token.keyword + person.name.replacingOccurrences(of: " ", with: "_") + " "
    }

    /// A note linked .to would never be waiting, so to: always captures a task.
    private func entryKind(_ parsed: ParsedCapture) -> EntryKind {
        if linkedTo?.link == .about { return .note }
        if parsed.to != nil || linkedTo?.link == .to { return .task }
        return kind
    }

    private func link(_ entry: Entry, _ parsed: ParsedCapture) {
        if let linkedTo {
            if linkedTo.link == .to {
                Review.delegate(entry, to: linkedTo.person)
            } else {
                entry.person = linkedTo.person
                entry.link = linkedTo.link
            }
        } else if let to = parsed.to, let person = try? PeopleDirectory.findOrCreate(to, in: context) {
            Review.delegate(entry, to: person)   // to: wins; from text stays on the entry
        } else if let from = parsed.from, let person = try? PeopleDirectory.findOrCreate(from, in: context) {
            entry.person = person
            entry.link = .from
        }
    }

    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    private func save() {
        guard !trimmed.isEmpty else { return }
        let parsed = CaptureParser.parse(trimmed)
        let kind = entryKind(parsed)
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
        withAnimation(.snappy) {
            context.insert(entry)
            link(entry, parsed)
            if kind == .task {
                entry.isPriority = parsed.isPriority
                entry.setRepeat(parsed.repeatRule)
            }
        }
        text = ""
        saved += 1
    }
}
