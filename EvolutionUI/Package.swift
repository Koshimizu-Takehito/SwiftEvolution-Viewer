// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// UI components and presentation logic for the Swift Evolution client.
let package = Package(
    name: "EvolutionUI",
    platforms: [
        .iOS(.v26), .macOS(.v15), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EvolutionUI",
            targets: ["EvolutionUI"]
        ),
    ],
    dependencies: [
        .package(path: "../EvolutionModel"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", .upToNextMinor(from: "0.6.0")),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", .upToNextMinor(from: "2.4.1")),
        .package(url: "https://github.com/JohnSundell/Splash.git", .upToNextMinor(from: "0.16.0")),
    ],
    targets: [
        .target(
            name: "EvolutionUI",
            dependencies: [
                "EvolutionModel",
                .product(name: "Markdown",   package: "swift-markdown"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Splash",     package: "Splash")
            ]
        ),
        .testTarget(
            name: "EvolutionUITests",
            dependencies: ["EvolutionUI"]
        ),
    ]
)
