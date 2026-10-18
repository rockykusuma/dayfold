import SwiftUI
import SwiftData
import DayfoldCore

/// One day page. Today by default; ‹ › and the date picker browse other days.
/// Past days are read-only except reopening a closed task.
struct DayPageView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.createdAt) private var allEntries: [Entry]
    @AppStorage("dayPage.scope") private var filter: ScopeFilter = .all
    @State private var day = Calendar.current.startOfDay(for: Date())
    @State private var editing: Entry?
    @State private var showReview = false
    @FocusState private var captureFocused: Bool

    private let calendar = Calendar.current
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var isToday: Bool { calendar.isDate(day, inSameDayAs: today) }
    private var isPast: Bool { day < today }

    private var items: [Entry] {
        DayPage.items(allEntries, on: day).filter { filter.includes($0.scope) }
    }
    private var pendingReview: [Entry] { Review.pending(allEntries, on: today) }

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { entry in
                    EntryRow(entry: entry, day: day) { toggle(entry) }
                        .swipeActions(edge: .leading) {
                            if entry.kind == .task && !isPast {
                                Button { toggle(entry) } label: {
                                    entry.status.isActive
                                        ? Label("Done", systemImage: "checkmark")
                                        : Label("Reopen", systemImage: "arrow.uturn.backward")
                                }
                                .tint(.green)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if entry.kind == .task && entry.status.isActive && !isPast {
                                Button { apply(.drop, to: entry) } label: { Label("Drop", systemImage: "xmark") }
                                    .tint(.red)
                                Button { apply(.push(to: nextDay), to: entry) } label: {
                                    Label("Tomorrow", systemImage: "arrow.turn.down.right")
                                }
                                .tint(.blue)
                            }
                        }
                        .contextMenu { menu(for: entry) }
                }
                if items.isEmpty {
                    Text(isPast ? "Nothing on this day." : "Nothing yet. Add the first thing someone asked you for.")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(isToday ? "Today" : day.formatted(.dateTime.weekday(.wide).day().month(.wide)))
            .safeAreaInset(edge: .top) { header }
            .safeAreaInset(edge: .bottom) {
                if !isPast { CaptureBar(filter: filter, day: day, focus: $captureFocused) }
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { showReview = true } label: {
                        Label("Review (\(pendingReview.count))", systemImage: "tray.full")
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .help("Review today's open tasks")

                    Button {
                        day = today
                        captureFocused = true
                    } label: { Label("New", systemImage: "square.and.pencil") }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
            .sheet(item: $editing) { EntryEditor(entry: $0) }
            .sheet(isPresented: $showReview) { ReviewView(entries: pendingReview) }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                Button { shift(-1) } label: { Image(systemName: "chevron.left") }
                    .keyboardShortcut(.leftArrow, modifiers: .command)
                    .accessibilityLabel("Previous day")
                Spacer()
                DatePicker("Day", selection: $day, displayedComponents: .date)
                    .labelsHidden()
                if !isToday {
                    Button("Today") { day = today }
                        .keyboardShortcut("t", modifiers: .command)
                }
                Spacer()
                Button { shift(1) } label: { Image(systemName: "chevron.right") }
                    .keyboardShortcut(.rightArrow, modifiers: .command)
                    .accessibilityLabel("Next day")
            }
            Picker("Scope", selection: $filter) {
                ForEach(ScopeFilter.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.bar)
    }

    @ViewBuilder
    private func menu(for entry: Entry) -> some View {
        if entry.kind == .task {
            if !entry.status.isActive {
                Button("Reopen", systemImage: "arrow.uturn.backward") { toggle(entry) }
            } else if !isPast {
                Button("Done", systemImage: "checkmark") { apply(.done, to: entry) }
                Button("Push to Tomorrow", systemImage: "arrow.turn.down.right") { apply(.push(to: nextDay), to: entry) }
                Button("Drop", systemImage: "xmark") { apply(.drop, to: entry) }
            }
        }
        if !isPast {
            Button("Edit…", systemImage: "pencil") { editing = entry }
            Button("Delete", systemImage: "trash", role: .destructive) { context.delete(entry) }
        }
    }

    /// The day after the page being viewed — tomorrow when on Today.
    private var nextDay: Date { calendar.date(byAdding: .day, value: 1, to: day) ?? day }

    private func shift(_ days: Int) {
        day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: day)) ?? day
    }

    private func apply(_ action: ReviewAction, to entry: Entry) {
        withAnimation { Review.apply(action, to: entry) }
    }

    /// Check circle: done ↔ open. On past days only reopening is allowed.
    private func toggle(_ entry: Entry) {
        withAnimation {
            if !entry.status.isActive {
                Review.reopen(entry)
            } else if !isPast {
                Review.apply(.done, to: entry)
            }
        }
    }
}

/// Edits apply live; SwiftData autosaves.
private struct EntryEditor: View {
    @Bindable var entry: Entry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Text", text: $entry.text, axis: .vertical)
                    .lineLimit(1...6)
                Picker("Kind", selection: $entry.kind) {
                    Text("Task").tag(EntryKind.task)
                    Text("Note").tag(EntryKind.note)
                }
                Picker("Scope", selection: $entry.scope) {
                    Text("Work").tag(EntryScope.work)
                    Text("Personal").tag(EntryScope.personal)
                }
                TextField("From", text: Binding(
                    get: { entry.from ?? "" },
                    set: { entry.from = $0.isEmpty ? nil : $0 }
                ))
                Toggle("Due date", isOn: Binding(
                    get: { entry.dueOn != nil },
                    set: { entry.dueOn = $0 ? Calendar.current.startOfDay(for: Date()) : nil }
                ))
                if let due = entry.dueOn {
                    DatePicker("Due", selection: Binding(get: { due }, set: { entry.dueOn = $0 }),
                               displayedComponents: .date)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

#Preview {
    DayPageView()
        .modelContainer(for: Entry.self, inMemory: true)
}
