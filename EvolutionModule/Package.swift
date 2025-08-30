// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// High-level feature modules composed from core models and UI components.
let package = Package(
    name: "EvolutionModule",
    platforms: [
        .iOS(.v26), .macOS(.v15), .tvOS(.v26), .watchOS(.v26), .visionOS(.v26),
    ],
    products: [
        .library(
            name: "EvolutionModule",
            targets: ["EvolutionModule"]
        ),
    ],
    dependencies: [
        .package(path: "../EvolutionModel"),
        .package(path: "../EvolutionUI"),
        .package(url: "https://github.com/swiftlang/swift-markdown.git", .upToNextMinor(from: "0.6.0")),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", .upToNextMinor(from: "2.4.1")),
        .package(url: "https://github.com/JohnSundell/Splash.git", .upToNextMinor(from: "0.16.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EvolutionModule",
            dependencies: [
                "EvolutionModel",
                "EvolutionUI",
                .product(name: "Markdown",   package: "swift-markdown"),
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Splash",     package: "Splash")
            ]
        ),
        .testTarget(
            name: "EvolutionModuleTests",
            dependencies: ["EvolutionModule"]
        ),
    ]
)
