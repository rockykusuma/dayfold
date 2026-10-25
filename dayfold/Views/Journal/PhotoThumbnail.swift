import SwiftUI
import DayfoldCore

/// A square, rounded photo. Decodes at thumbnail size only, once per `data`.
struct PhotoThumbnail: View {
    let data: Data?
    let size: CGFloat
    @Environment(\.displayScale) private var scale
    @State private var image: CGImage?

    init(data: Data?, size: CGFloat) {
        self.data = data
        self.size = size
    }

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
        .task(id: data) {
            // long side ×2 so a photo up to 2:1 still fills the square sharply
            image = data.flatMap { PhotoImport.thumbnail($0, maxPixel: Int(size * scale * 2)) }
        }
    }
}
