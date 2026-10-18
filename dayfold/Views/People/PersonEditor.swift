import SwiftUI
import SwiftData
import DayfoldCore

/// Name, role, team; merge or delete. Saving marks the person as sorted.
struct PersonEditor: View {
    @Bindable var person: Person
    /// Called before a merge/delete so the person page can close first.
    var onRemoved: () -> Void
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDelete = false
    @State private var merging = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $person.name)
                }
                Section {
                    Picker("Role", selection: $person.role) {
                        ForEach(PersonRole.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    TextField("Team", text: Binding(
                        get: { person.team ?? "" },
                        set: {
                            let team = $0.trimmingCharacters(in: .whitespaces)
                            person.team = team.isEmpty ? nil : team
                        }
                    ), prompt: Text("e.g. Platform"))
                }
                Section {
                    Button("Merge with…") { merging = true }
                    Button("Delete \(person.name)…", role: .destructive) { confirmDelete = true }
                } footer: {
                    Text("Merging moves everything onto the other person. Deleting keeps entries, unlinked.")
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Edit")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        person.isSorted = true
                        dismiss()
                    }
                }
            }
            .confirmationDialog("Delete \(person.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    remove { PeopleDirectory.delete(person, in: context) }
                }
            } message: {
                Text("\(person.entries?.count ?? 0) entries stay, unlinked.")
            }
            .sheet(isPresented: $merging) {
                PeoplePicker(title: "Merge into", excluding: person) { keeper in
                    remove { PeopleDirectory.merge(person, into: keeper, in: context) }
                }
            }
        }
        .frame(minWidth: 380, minHeight: 360)
    }

    /// Close this sheet and the person page, then change the store, so no view reads a deleted person.
    private func remove(_ change: @escaping () -> Void) {
        dismiss()
        onRemoved()
        DispatchQueue.main.async {
            withAnimation { change() }
            try? context.save()
        }
    }
}
