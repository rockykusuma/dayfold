import SwiftUI
import DayfoldCore

/// Which journal entry the editor sheet shows: an existing one, or a new one dated `date`.
struct JournalEditorTarget: Identifiable {
    let id = UUID()
    var entry: JournalEntry?
    var date = Date()
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
                    Text(entry.preview).lineLimit(2).multilineTextAlignment(.leading)
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
