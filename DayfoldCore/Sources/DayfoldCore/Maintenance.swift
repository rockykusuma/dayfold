import Foundation
import SwiftData

public enum Maintenance {
    /// Run at launch and whenever the app comes to the foreground: link legacy `from:` text,
    /// merge duplicate people, remove duplicate repeat occurrences, remove blank note pages untouched for a day.
    public static func tidy(in context: ModelContext, now: Date = Date()) throws {
        try PeopleDirectory.backfillFromText(in: context)
        try PeopleDirectory.mergeDuplicates(in: context)
        try Recurrence.dedupe(in: context)
        try Journal.migrateDayNotes(in: context)
        try Journal.dedupe(in: context)
        // Blank pages left behind by a kill mid-edit (leaving edit mode removes them otherwise).
        let cutoff = now.addingTimeInterval(-24 * 60 * 60)
        for page in try context.fetch(FetchDescriptor<NotePage>()) where page.isBlank && page.updatedAt < cutoff {
            Pages.delete(page, in: context)
        }
        try context.save()
    }
}
