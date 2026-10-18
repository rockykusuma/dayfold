// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DayfoldCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DayfoldCore", targets: ["DayfoldCore"]),
    ],
    targets: [
        .target(
            name: "DayfoldCore",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "DayfoldCoreTests",
            dependencies: ["DayfoldCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
