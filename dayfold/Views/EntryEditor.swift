import SwiftUI
import SwiftData
import DayfoldCore

/// Edits apply live; SwiftData autosaves.
struct EntryEditor: View {
    @Bindable var entry: Entry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var changingPerson = false
    @State private var tagsText = ""
    @State private var newItem = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Text", text: $entry.text, axis: .vertical)
                        .lineLimit(1...6)
                }
                Section {
                    Picker("Kind", selection: $entry.kind) {
                        Text("Task").tag(EntryKind.task)
                        Text("Note").tag(EntryKind.note)
                    }
                    Picker("Scope", selection: $entry.scope) {
                        Label("Work", systemImage: "briefcase").tag(EntryScope.work)
                        Label("Personal", systemImage: "house").tag(EntryScope.personal)
                    }
                    if let person = entry.person {
                        LabeledContent(entry.link == .to ? "Waiting on" : entry.link == .about ? "About" : "Asked by",
                                       value: person.name)
                        Button("Change…") { changingPerson = true }
                            .frame(minHeight: 44)
                        Button("Remove person", role: .destructive) {
                            entry.person = nil
                            entry.linkRaw = ""
                        }
                        .frame(minHeight: 44)
                    } else {
                        TextField("From", text: Binding(
                            get: { entry.from ?? "" },
                            set: { entry.from = $0.isEmpty ? nil : $0 }
                        ), prompt: Text("Who asked?"))
                    }
                }
                Section {
                    Toggle("Due date", isOn: Binding(
                        get: { entry.dueOn != nil },
                        set: { entry.dueOn = $0 ? Calendar.current.startOfDay(for: Date()) : nil }
                    ).animation())
                    if let due = entry.dueOn {
                        DatePicker("Due", selection: Binding(get: { due }, set: { entry.dueOn = $0 }),
                                   displayedComponents: .date)
                    }
                }
                if entry.kind == .task {
                    Section {
                        Toggle("Priority", isOn: $entry.isPriority)
                        Picker("Repeat", selection: Binding<RepeatRule?>(
                            get: { entry.repeatRule?.choice },
                            set: { entry.setRepeat($0) }
                        )) {
                            Text("Never").tag(RepeatRule?.none)
                            ForEach([RepeatRule.daily, .weekdays, .weekly, .monthly(day: nil)], id: \.self) {
                                Text($0.title).tag(RepeatRule?.some($0))
                            }
                        }
                    }
                }
                Section("Tags") {
                    TextField("Tags", text: $tagsText, prompt: Text("hiring, roadmap"))
                        .onChange(of: tagsText) { entry.tags = Tags.parse(tagsText) }
                }
                if entry.kind == .task {
                    Section("Checklist") {
                        ForEach(entry.sortedChecklist) { item in
                            HStack {
                                Button {
                                    item.isDone.toggle()
                                } label: {
                                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(item.isDone ? "Mark not done" : "Mark done")
                                Text(item.text).strikethrough(item.isDone)
                            }
                        }
                        .onDelete { offsets in
                            let items = entry.sortedChecklist
                            offsets.forEach { context.delete(items[$0]) }
                        }
                        .onMove { Checklist.move(in: entry, from: $0, to: $1) }
                        TextField("Add item", text: $newItem)
                            .frame(minHeight: 44)
                            .onSubmit {
                                Checklist.add(newItem, to: entry, in: context)
                                newItem = ""
                            }
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .onAppear { tagsText = entry.tags.joined(separator: " ") }
            .onChange(of: entry.kind) {
                if entry.kind == .note {
                    entry.setRepeat(nil)
                    entry.isPriority = false
                }
            }
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
            .sheet(isPresented: $changingPerson) {
                PeoplePicker(title: "Change person") { picked in
                    entry.person = picked
                    if entry.link == nil { entry.link = .from }
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 380, minHeight: 520)
        #endif
    }
}
