import Foundation

public enum JournalSuggestionKind: Equatable { case fromYourDay, prompt }

public struct JournalSuggestion: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let detail: String
    public let kind: JournalSuggestionKind
}

/// Writing starters: up to 3 drawn from the day's tasks, then 3 rotating prompts.
public enum JournalSuggestions {
    static let prompts = ["What made today good?", "What's on your mind for tomorrow?", "Who helped you today?",
                          "What did you learn today?", "What would you do differently?", "What are you grateful for?"]

    public static func make(tasks: [Entry], day: Date, now: Date = Date(), calendar: Calendar = .current) -> [JournalSuggestion] {
        let tasks = tasks.filter { $0.kind == .task }
        func item(_ title: String, _ detail: String) -> JournalSuggestion {
            JournalSuggestion(id: title, title: title, detail: detail, kind: .fromYourDay)
        }
        func quote(_ e: Entry) -> String { "“\(e.text)”" }
        var out: [JournalSuggestion] = []

        let finished = tasks.filter { $0.status == .done && $0.closedAt.map { calendar.isDate($0, inSameDayAs: day) } == true }
        if let last = finished.max(by: { $0.closedAt! < $1.closedAt! }) {
            out.append(item("You finished \(finished.count) \(finished.count == 1 ? "thing" : "things")",
                            "Including " + quote(last) + (last.person.map { " for \($0.name)" } ?? "")))
        }
        let active = tasks.filter { $0.status.isActive }
        if let owed = active.filter({ $0.isWaiting && $0.person != nil }).max(by: { Review.waitingDays($0, on: day, calendar: calendar) < Review.waitingDays($1, on: day, calendar: calendar) }),
           Review.waitingDays(owed, on: day, calendar: calendar) >= 3 {
            out.append(item("\(owed.person!.name) has owed you this for \(Review.waitingDays(owed, on: day, calendar: calendar))d", quote(owed)))
        }
        if let old = active.filter({ !$0.isWaiting && $0.showOn <= day }).min(by: { $0.createdAt < $1.createdAt }),
           DayPage.age(of: old, on: day, calendar: calendar) >= 3 {
            out.append(item("Open for \(DayPage.age(of: old, on: day, calendar: calendar))d", quote(old)))
        }
        if let asked = tasks.filter({ $0.link == .from && $0.person != nil && calendar.isDate($0.createdAt, inSameDayAs: day) })
            .max(by: { $0.createdAt < $1.createdAt }) {
            out.append(item("\(asked.person!.name) asked you" + (calendar.isDate(day, inSameDayAs: now) ? " today" : ""), quote(asked)))
        }

        let start = (calendar.ordinality(of: .day, in: .year, for: day) ?? 0) % prompts.count
        let picked = (0..<3).map { prompts[(start + $0) % prompts.count] }
        return Array(out.prefix(3)) + picked.map { JournalSuggestion(id: $0, title: $0, detail: "", kind: .prompt) }
    }
}
