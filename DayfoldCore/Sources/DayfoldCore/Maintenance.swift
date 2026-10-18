import SwiftData

public enum Maintenance {
    /// Run at launch and whenever the app comes to the foreground: link legacy `from:` text,
    /// merge duplicate people, remove duplicate repeat occurrences.
    public static func tidy(in context: ModelContext) throws {
        try PeopleDirectory.backfillFromText(in: context)
        try PeopleDirectory.mergeDuplicates(in: context)
        try Recurrence.dedupe(in: context)
        try context.save()
    }
}
