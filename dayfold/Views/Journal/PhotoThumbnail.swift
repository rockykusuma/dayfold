import SwiftUI
import DayfoldCore

/// A square, rounded photo. Decodes at thumbnail size only, off the main actor, once per `id`.
struct PhotoThumbnail: View {
    /// Stable per photo, so a parent re-render never re-reads or re-decodes.
    let id: UUID
    let size: CGFloat
    /// Read once per `id`, on the main actor: a SwiftData model can't be touched from a detached task.
    let data: () -> Data?
    @Environment(\.displayScale) private var scale
    @State private var image: CGImage?

    var body: some View {
        ZStack {
            Color.card
            if let image {
                Image(decorative: image, scale: 1).resizable().scaledToFill()
            } else {
                Image(systemName: "photo").foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .accessibilityHidden(true)
        .task(id: id) {
            guard let bytes = data() else { image = nil; return }
            let maxPixel = Int(size * scale * 2)   // long side ×2 so a photo up to 2:1 still fills the square sharply
            let decoded = await Task.detached { PhotoImport.thumbnail(bytes, maxPixel: maxPixel) }.value
            image = decoded
        }
    }
}
