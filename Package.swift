// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent-mysql.git", .branch("beta")),
        .package(url: "https://github.com/vapor/auth.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
        .package(url: "https://github.com/vapor/leaf.git", .branch("beta"))
    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Vapor", "Fluent", "FluentMySQL", "Authentication", "Leaf"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)
