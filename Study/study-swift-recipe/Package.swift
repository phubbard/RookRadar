// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SwiftRecipeDemo",
    dependencies: [
        // Dependencies go here
    ],
    targets: [
        .executableTarget(
            name: "SwiftRecipeDemo",
            dependencies: []),
        .testTarget(
            name: "SwiftRecipeDemoTests",
            dependencies: ["SwiftRecipeDemo"]),
    ]
)
