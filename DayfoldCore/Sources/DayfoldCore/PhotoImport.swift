import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Imported photos are stored downscaled as JPEG, never the original bytes.
public enum PhotoImport {
    /// Long side at most `maxPixel` (never upscaled), orientation applied, JPEG at `quality`. Nil if undecodable.
    public static func downscaled(_ data: Data, maxPixel: Int = 2048, quality: Double = 0.8) -> Data? {
        guard let image = thumbnail(data, maxPixel: maxPixel) else { return nil }
        let out = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(out, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(dest, image, [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary)
        return CGImageDestinationFinalize(dest) ? out as Data : nil
    }

    /// Decoded image with long side at most `maxPixel`, orientation applied. Also used for on-screen thumbnails.
    public static func thumbnail(_ data: Data, maxPixel: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil), CGImageSourceGetCount(source) > 0 else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}
