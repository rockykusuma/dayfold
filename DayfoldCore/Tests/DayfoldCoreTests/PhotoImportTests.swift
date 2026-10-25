import Foundation
import Testing
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
@testable import DayfoldCore

@Suite("Photo import")
struct PhotoImportTests {
    /// A solid-colour image encoded as PNG.
    func png(_ width: Int, _ height: Int) -> Data {
        let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.setFillColor(CGColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let out = NSMutableData()
        let dest = CGImageDestinationCreateWithData(out, UTType.png.identifier as CFString, 1, nil)!
        CGImageDestinationAddImage(dest, ctx.makeImage()!, nil)
        #expect(CGImageDestinationFinalize(dest))
        return out as Data
    }

    /// (type identifier, width, height) of encoded image data.
    func info(_ data: Data) -> (String, Int, Int)? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let type = CGImageSourceGetType(src) as String?,
              let image = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
        return (type, image.width, image.height)
    }

    @Test func downscalesLargeImage() throws {
        let original = png(4032, 3024)
        let out = try #require(PhotoImport.downscaled(original))
        let (type, w, h) = try #require(info(out))
        #expect(type == "public.jpeg")
        #expect(max(w, h) <= 2048)
        #expect(w == 2048)
        #expect(abs(h - 2048 * 3024 / 4032) <= 1)
        #expect(out != original)
    }

    @Test func keepsSmallImage() throws {
        let out = try #require(PhotoImport.downscaled(png(800, 600)))
        let (type, w, h) = try #require(info(out))
        #expect(type == "public.jpeg")
        #expect(w == 800 && h == 600)
    }

    @Test func rejectsGarbage() {
        #expect(PhotoImport.downscaled(Data("x".utf8)) == nil)
    }
}
