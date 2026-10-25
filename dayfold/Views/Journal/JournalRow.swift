import SwiftUI
import DayfoldCore

extension JournalEntry {
    /// `preview`, or "Photo" / "Untitled entry" when there's no title or text.
    var displayPreview: String {
        let p = preview
        return !p.isEmpty ? p : hasPhotos ? "Photo" : "Untitled entry"
    }
}

/// Compact journal row for the Day page and Search. Whole row tappable, 44pt minimum.
struct JournalRow: View {
    let entry: JournalEntry
    var showDate = false
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 12) {
                Image(systemName: "book.closed").foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    if showDate {
                        Text(entry.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Text(entry.displayPreview).lineLimit(2).multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                if entry.hasPhotos { Image(systemName: "photo").foregroundStyle(.secondary).accessibilityLabel("Has photos") }
                if entry.isBookmarked { Image(systemName: "bookmark.fill").foregroundStyle(.secondary).accessibilityLabel("Bookmarked") }
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
