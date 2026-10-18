import SwiftUI
import SwiftData
import DayfoldCore

/// Search, pick, or add a person. Used by Delegate and Merge.
struct PeoplePicker: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Person.name) private var people: [Person]
    @State private var search = ""
    let title: String
    var excluding: Person? = nil
    let onPick: (Person) -> Void

    private var key: String { PeopleDirectory.normalize(search) }
    private var candidates: [Person] {
        people.filter { $0.id != excluding?.id && (key.isEmpty || PeopleDirectory.normalize($0.name).contains(key)) }
    }
    /// "Add …" only when picking for delegation and nobody has exactly this name.
    private var canAdd: Bool {
        excluding == nil && !key.isEmpty && !people.contains { PeopleDirectory.normalize($0.name) == key }
    }

    var body: some View {
        NavigationStack {
            List {
                if canAdd {
                    Button { pick(PeopleDirectory.create(search, in: context)) } label: {
                        Label("Add “\(PeopleDirectory.displayName(search))”", systemImage: "person.badge.plus")
                    }
                }
                ForEach(candidates) { person in
                    Button { pick(person) } label: { PersonLabel(person: person) }
                        .buttonStyle(.plain)
                }
            }
            .searchable(text: $search, prompt: "Name")
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 420)
        #endif
    }

    private func pick(_ person: Person?) {
        guard let person else { return }
        onPick(person)
        dismiss()
    }
}

/// Initials avatar, name, and "team · role".
struct PersonLabel: View {
    let person: Person
    @ScaledMetric(relativeTo: .body) private var avatar: CGFloat = 32

    var body: some View {
        HStack(spacing: 10) {
            Text(initials)
                .font(.caption.weight(.bold))
                .foregroundStyle(.tint)
                .frame(width: avatar, height: avatar)
                .background(Color.accentColor.opacity(0.15), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }

    private var initials: String {
        PeopleDirectory.displayName(person.name).split(separator: " ").prefix(2)
            .compactMap(\.first).map(String.init).joined()
    }

    private var subtitle: String {
        [person.team, person.role.title].compactMap { $0 }.joined(separator: " · ")
    }
}

extension PersonRole {
    var title: String {
        switch self {
        case .report: "Direct report"
        case .manager: "Manager"
        case .peer: "Peer"
        case .other: "Other"
        }
    }
}
