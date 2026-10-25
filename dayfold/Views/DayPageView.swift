import SwiftUI
import SwiftData
import DayfoldCore

/// One day page. Today by default; ‹ › and the date (tap for a calendar) browse other days.
/// Past days are read-only except reopening a closed task.
struct DayPageView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.createdAt) private var allEntries: [Entry]
    @AppStorage("dayPage.scope") private var filter: ScopeFilter = .all
    @State private var day = Calendar.current.startOfDay(for: Date())
    @Query(sort: \JournalEntry.date) private var journal: [JournalEntry]
    @State private var editing: Entry?
    @State private var journalEditing: JournalEditorTarget?
    @State private var delegating: Entry?
    @State private var openedPerson: Person?
    @State private var showCalendar = false
    #if DEBUG
    @State private var showSettings = CommandLine.arguments.contains("-settings")
    #else
    @State private var showSettings = false
    #endif
    @Bindable private var reminder = ReviewReminder.shared
    @AppStorage("review.nudgeAfter") private var nudgeAfter = 3
    @FocusState private var captureFocused: Bool

    private let calendar = Calendar.current
    private var today: Date { calendar.startOfDay(for: Date()) }
    private var isToday: Bool { calendar.isDate(day, inSameDayAs: today) }
    private func consumeCaptureRequest() {
        guard CaptureRouter.shared.pending else { return }
        CaptureRouter.shared.consume()
        day = today
        // After RootView's tab/sidebar switch has landed.
        Task { @MainActor in captureFocused = true }
    }

    private var isPast: Bool { day < today }
    private var isFuture: Bool { day > today }
    private var noon: Date { calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day }
    private var dayJournal: [JournalEntry] { journal.filter { calendar.isDate($0.date, inSameDayAs: day) } }
    /// Hidden while the journal is locked; its editor sheet hangs off the List, so hiding never dismisses it.
    private var showJournal: Bool { !JournalLock.shared.isLocked && (!isFuture || !dayJournal.isEmpty) }

    private var items: [Entry] {
        DayPage.items(allEntries, on: day).filter { filter.includes($0.scope) }
    }
    /// Tonight's Review: own tasks, then waiting items past the nudge threshold.
    private var pendingReview: [Entry] { Review.queue(allEntries, on: today, nudgeAfter: nudgeAfter) }

    var body: some View {
        NavigationStack {
            List {
                header
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                let split = DayPage.prioritySplit(items)
                if !split.priority.isEmpty {
                    Section {
                        ForEach(split.priority) { row($0) }
                    } header: {
                        Text("Priority")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                    }
                }
                ForEach(split.timeline) { row($0) }

                if showJournal {
                    Section {
                        ForEach(dayJournal) { e in
                            JournalRow(entry: e) { journalEditing = JournalEditorTarget(entry: e) }
                                .listRowBackground(Color.clear)
                        }
                        if !isFuture {
                            Button { journalEditing = JournalEditorTarget(date: isToday ? Date() : noon) } label: {
                                Label("Write about this day", systemImage: "square.and.pencil")
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.tint)
                            .listRowBackground(Color.clear)
                        }
                    } header: {
                        Text("Journal")
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                    }
                }

                if items.isEmpty {
                    emptyState
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .scrollDismissesKeyboard(.interactively)
            .dropDestination(for: String.self) { items, _ in
                guard !isPast else { return false }
                return withAnimation(.snappy) {
                    !Capture.addLines(items.joined(separator: "\n"), scope: filter.defaultScope ?? .lastUsed,
                                      day: day, in: context).isEmpty
                }
            }
            .onAppear(perform: consumeCaptureRequest)
            .onChange(of: CaptureRouter.shared.requests, consumeCaptureRequest)
            #if os(macOS)
            .navigationTitle("Dayfold")
            #else
            .toolbarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .bottom) {
                if !isPast { CaptureBar(filter: filter, day: day, focus: $captureFocused) }
            }
            .toolbar { toolbar }
            .sheet(item: $editing) { EntryEditor(entry: $0) }
            .sheet(item: $journalEditing) { JournalEditor(entry: $0.entry, date: $0.date) }
            #if DEBUG
            // `-edit <text prefix>` opens the editor for the first matching entry (screenshots can't tap).
            .task {
                let args = CommandLine.arguments
                guard let i = args.firstIndex(of: "-edit"), i + 1 < args.count else { return }
                editing = allEntries.first { $0.text.hasPrefix(args[i + 1]) }
            }
            #endif
            .navigationDestination(item: $openedPerson) { PersonView(person: $0) }
            .sheet(item: $delegating) { entry in
                PeoplePicker(title: "Delegate to") { person in
                    withAnimation(.snappy) { Review.delegate(entry, to: person) }
                }
            }
            .sheet(isPresented: $reminder.showReview) { ReviewView(entries: pendingReview) }
            #if os(iOS)
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) { Button("Done") { showSettings = false } }
                        }
                }
            }
            #endif
        }
    }

    private func row(_ entry: Entry) -> some View {
        EntryRow(entry: entry, day: day, showScope: filter == .all) { toggle(entry) } onPerson: { openedPerson = $0 }
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 20))
            .listRowBackground(Color.clear)
            .swipeActions(edge: .leading) {
                if entry.kind == .task && !isPast {
                    Button { toggle(entry) } label: {
                        entry.status.isActive
                            ? Label(entry.isWaiting ? "Got it" : "Done", systemImage: "checkmark")
                            : Label("Reopen", systemImage: "arrow.uturn.backward")
                    }
                    .tint(.green)
                    if entry.status.isActive { starButton(entry).tint(.accentColor) }
                }
            }
            .swipeActions(edge: .trailing) {
                if entry.kind == .task && entry.status.isActive && !isPast {
                    Button { apply(.drop, to: entry) } label: { Label("Drop", systemImage: "xmark") }
                        .tint(.red)
                    Button { apply(.push(to: nextDay), to: entry) } label: {
                        Label("Tomorrow", systemImage: "arrow.turn.down.right")
                    }
                    .tint(.accentColor)
                    if !entry.isWaiting {
                        Button { delegating = entry } label: { Label("Delegate", systemImage: "person.fill.turn.right") }
                            .tint(.orange)
                    }
                }
            }
            .contextMenu { menu(for: entry) }
            .sensoryFeedback(.selection, trigger: entry.isPriority)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 4) {
                Button { showCalendar = true } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(relativeLabel)
                            .font(.caption.weight(.semibold))
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .foregroundStyle(isToday ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        Text(day, format: dateFormat)
                            .font(.system(.largeTitle, design: .serif, weight: .semibold))
                            .contentTransition(.numericText())
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens a calendar")
                .popover(isPresented: $showCalendar) {
                    DatePicker("Go to day", selection: Binding(
                        get: { day },
                        set: { new in withAnimation(.snappy) { day = calendar.startOfDay(for: new) }; showCalendar = false }
                    ), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .padding()
                    .frame(minWidth: 320)
                    .presentationCompactAdaptation(.popover)
                }

                Spacer(minLength: 8)

                if !isToday {
                    Button("Today") { withAnimation(.snappy) { day = today } }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .controlSize(.small)
                        .keyboardShortcut("t", modifiers: .command)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
                dayButton(-1, symbol: "chevron.left", label: "Previous day", key: .leftArrow)
                dayButton(1, symbol: "chevron.right", label: "Next day", key: .rightArrow)
            }

            if let progress {
                HStack(spacing: 10) {
                    ProgressView(value: Double(progress.done), total: Double(progress.total))
                        .tint(.accentColor)
                    Text("\(progress.done) of \(progress.total) done")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .contentTransition(.numericText())
                }
                .accessibilityElement(children: .combine)
            }

            Picker("Scope", selection: $filter.animation(.snappy)) {
                ForEach(ScopeFilter.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .dynamicTypeSize(...DynamicTypeSize.accessibility1) // display text; rows below scale fully
    }

    private func dayButton(_ offset: Int, symbol: String, label: String, key: KeyEquivalent) -> some View {
        Button { shift(offset) } label: {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.tint)
        .keyboardShortcut(key, modifiers: .command)
        .accessibilityLabel(label)
    }

    private var relativeLabel: String {
        let weekday = day.formatted(.dateTime.weekday(.wide))
        if isToday { return "Today · \(weekday)" }
        if calendar.isDateInYesterday(day) { return "Yesterday · \(weekday)" }
        if calendar.isDateInTomorrow(day) { return "Tomorrow · \(weekday)" }
        return weekday
    }

    private var dateFormat: Date.FormatStyle {
        calendar.isDate(day, equalTo: today, toGranularity: .year)
            ? .dateTime.day().month(.wide)
            : .dateTime.day().month(.wide).year()
    }

    /// Tasks on this page and how many are done. Nil when there are no tasks.
    private var progress: (done: Int, total: Int)? {
        let tasks = items.filter { $0.kind == .task }
        guard !tasks.isEmpty else { return nil }
        return (tasks.filter { $0.status == .done }.count, tasks.count)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "pencil.line")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)
            Text(isPast ? "Nothing on this day" : "A blank page")
                .font(.system(.title3, design: .serif, weight: .semibold))
            Text(isPast ? "Nothing was logged or open." : "Add the first thing someone asked you for.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            Button { showSettings = true } label: { Label("Settings", systemImage: "gearshape") }
        }
        #endif
        ToolbarItemGroup(placement: .primaryAction) {
            Button { reminder.showReview = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: pendingReview.isEmpty ? "tray" : "tray.full")
                    if !pendingReview.isEmpty {
                        Text("\(pendingReview.count)").monospacedDigit()
                    }
                }
            }
            .keyboardShortcut("r", modifiers: .command)
            .help("Review today's open tasks")
            .accessibilityLabel("Review, \(pendingReview.count) open")

            #if os(macOS)
            Button { CaptureRouter.shared.request() } label: { Label("New", systemImage: "square.and.pencil") }
            .help("New entry")
            #endif
        }
    }

    // MARK: Actions

    @ViewBuilder
    private func menu(for entry: Entry) -> some View {
        if entry.kind == .task {
            if !entry.status.isActive {
                Button("Reopen", systemImage: "arrow.uturn.backward") { toggle(entry) }
            } else if !isPast {
                Button("Done", systemImage: "checkmark") { apply(.done, to: entry) }
                Button("Push to Tomorrow", systemImage: "arrow.turn.down.right") { apply(.push(to: nextDay), to: entry) }
                Button("Drop", systemImage: "xmark") { apply(.drop, to: entry) }
                starButton(entry)
                if entry.repeatRule != nil {
                    Button("Stop repeating", systemImage: "stop.circle") { entry.setRepeat(nil) }
                }
                Button(entry.isWaiting ? "Delegate to Someone Else…" : "Delegate to…",
                       systemImage: "person.fill.turn.right") { delegating = entry }
            }
        }
        if !isPast {
            Divider()
            Button("Edit…", systemImage: "pencil") { editing = entry }
            Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation { context.delete(entry) }
            }
        }
    }

    private func starButton(_ entry: Entry) -> some View {
        Button { star(entry) } label: {
            Label(entry.isPriority ? "Unstar" : "Star", systemImage: entry.isPriority ? "star.slash" : "star")
        }
    }

    private func star(_ entry: Entry) {
        withAnimation(.snappy) { entry.isPriority.toggle() }
    }

    /// The day after the page being viewed — tomorrow when on Today.
    private var nextDay: Date { calendar.date(byAdding: .day, value: 1, to: day) ?? day }

    private func shift(_ days: Int) {
        withAnimation(.snappy) {
            day = calendar.date(byAdding: .day, value: days, to: calendar.startOfDay(for: day)) ?? day
        }
    }

    private func apply(_ action: ReviewAction, to entry: Entry) {
        withAnimation(.snappy) { Review.apply(action, to: entry, context: context) }
    }

    /// Check circle: done ↔ open. On past days only reopening is allowed.
    private func toggle(_ entry: Entry) {
        withAnimation(.snappy) {
            if !entry.status.isActive {
                Review.reopen(entry)
            } else if !isPast {
                Review.apply(.done, to: entry, context: context)
            }
        }
    }
}

#if DEBUG
#Preview {
    DayPageView()
        .modelContainer(DemoData.container())
}
#endif
