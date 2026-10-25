import Foundation
import SwiftData
import Testing
@testable import DayfoldCore

@MainActor
func makeContainer() -> ModelContainer {
    try! ModelContainer(for: Entry.self, Person.self, ChecklistItem.self, DayNote.self, JournalEntry.self, JournalPhoto.self,
                        configurations: ModelConfiguration(isStoredInMemoryOnly: true))
}

@Suite("People model") @MainActor
struct PeopleModelTests {
    // Keep the container alive for the whole test; a context alone doesn't retain it.
    let container = makeContainer()
    var context: ModelContext { container.mainContext }

    @Test func personDefaults() {
        let p = Person(name: "Priya")
        #expect(p.role == .other)
        #expect(p.team == nil)
        #expect(p.isSorted == false)
    }

    @Test("Linking an entry shows it on the person and makes it waiting")
    func linkRoundTrip() throws {
        let p = Person(name: "Priya")
        let e = Entry(text: "Q4 numbers")
        context.insert(p); context.insert(e)
        e.person = p
        e.link = .to
        try context.save()
        #expect(p.entries?.contains { $0.id == e.id } == true)
        #expect(e.isWaiting)
    }

    @Test("A 'to' link with no person is not waiting (deleted elsewhere)")
    func orphanLinkIsNotWaiting() {
        let e = Entry(text: "x")
        e.linkRaw = PersonLink.to.rawValue
        #expect(e.link == nil)
        #expect(e.isWaiting == false)
    }
}
