// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PrintUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PrintUI",
            targets: ["PrintUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.57.0"),
    ],
    targets: [
        .target(
            name: "PrintUI",
            swiftSettings: [
                .enableExperimentalFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
                .swiftLanguageMode(.v6)
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "PrintUITests",
            dependencies: ["PrintUI"],
            swiftSettings: [
                .enableExperimentalFeature("ApproachableConcurrency"),
                .defaultIsolation(MainActor.self),
                .swiftLanguageMode(.v6)
            ],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
            ]
        ),
    ]
)
