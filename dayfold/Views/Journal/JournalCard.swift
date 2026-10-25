import SwiftUI
import DayfoldCore

/// One entry in the Journal feed: date line, title, a few lines of text, up to 4 photos.
struct JournalCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated))) · \(entry.date.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 8)
                if entry.isBookmarked {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(.tint)
                        .accessibilityLabel("Bookmarked")
                }
            }
            let hasTitle = !entry.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasText = !entry.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if hasTitle {
                Text(entry.title)
                    .font(.system(.headline, design: .serif, weight: .semibold))
            }
            if hasText {
                Text(entry.text)
                    .lineLimit(4)
            }
            if !hasTitle && !hasText {
                Text(entry.displayPreview)
                    .foregroundStyle(.secondary)
            }
            if entry.hasPhotos {
                HStack(spacing: 6) {
                    ForEach(entry.sortedPhotos.prefix(4)) { PhotoThumbnail(data: $0.data, size: 64) }
                }
            }
            if entry.isReflection {
                Text("Evening reflection")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
