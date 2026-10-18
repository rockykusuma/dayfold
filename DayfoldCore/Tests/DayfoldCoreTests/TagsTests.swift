import Testing
import Foundation
@testable import DayfoldCore

@Suite("Tags")
struct TagsTests {
    private func entry(_ tags: [String], _ hour: Int) -> Entry {
        Entry(text: "x", createdAt: at(2026,10,19,hour), tags: tags, calendar: ist)
    }

    @Test("Spelling variants are one tag")   // Review Focus 4
    func keyNormalizes() {
        let k = Tags.key("hiring")
        for v in ["#Hiring", "HIRING", "hiring,", "#hiring.", "híring"] { #expect(Tags.key(v) == k) }
        #expect(Tags.key("hiring-plan") != k)
    }

    @Test("Counted per entry, newest spelling shown, by count then name")
    func all() {
        let tags = Tags.all([
            entry(["hiring"], 9), entry(["Hiring", "roadmap"], 12), entry(["hiring,", "#hiring"], 8),
            entry(["roadmap"], 10), entry(["ops"], 11), entry(["admin"], 7),
        ])
        #expect(tags.map(\.tag) == ["Hiring", "roadmap", "admin", "ops"])
        #expect(tags.map(\.count) == [3, 2, 1, 1])
    }

    @Test func parseEditorField() {
        #expect(Tags.parse("#hiring, roadmap  #Hiring ,, q4") == ["hiring", "roadmap", "q4"])
        #expect(Tags.parse(" , ") == [])
    }

    @Test func displayCleansAndDedupes() {
        #expect(Tags.display(["hiring,", "Hiring", "#ops.", "#,", "ops"]) == ["hiring", "ops"])
        #expect(Tags.display([]) == [])
    }
}
