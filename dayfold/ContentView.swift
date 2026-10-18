import SwiftUI
import SwiftData
import DayfoldCore

/// v0.1 placeholder day page: proves the model, sync and rollover rule end to end.
/// Replaced by the real DayPageView once the loop is working.
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Entry.createdAt) private var allEntries: [Entry]
    @State private var draft = ""

    private var today: Date { Date() }
    private var todaysItems: [Entry] { DayPage.items(allEntries, on: today) }

    var body: some View {
        NavigationStack {
            List {
                Section(today.formatted(date: .complete, time: .omitted)) {
                    ForEach(todaysItems) { entry in
                        row(entry)
                    }
                    if todaysItems.isEmpty {
                        Text("Nothing yet. Add the first thing someone asked you for.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Dayfold")
            .safeAreaInset(edge: .bottom) { captureBar }
        }
    }

    private func row(_ entry: Entry) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            if entry.kind == .task {
                Button {
                    toggle(entry)
                } label: {
                    Image(systemName: entry.status.isActive ? "circle" : "checkmark.circle.fill")
                }
                .buttonStyle(.plain)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .strikethrough(!entry.status.isActive)
                HStack(spacing: 6) {
                    Text(entry.createdAt, format: .dateTime.hour().minute())
                    Text(entry.scope.rawValue.capitalized)
                    let age = DayPage.age(of: entry, on: today)
                    if age > 0 { Text("\(age)d") }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var captureBar: some View {
        HStack {
            TextField("Add a task…", text: $draft)
                .textFieldStyle(.roundedBorder)
                .onSubmit(add)
            Button("Add", action: add).disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(.bar)
    }

    private func add() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        context.insert(Entry(text: text))
        draft = ""
    }

    private func toggle(_ entry: Entry) {
        if entry.status.isActive {
            Review.apply(.done, to: entry)
        } else {
            Review.reopen(entry)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Entry.self, inMemory: true)
}
