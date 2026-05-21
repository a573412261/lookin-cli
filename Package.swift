// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "lookin-cli",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "lookin-cli", targets: ["LookinCLI"]),
    ],
    dependencies: [
        // LookinShared - shared protocol & models from LookinServer
        // .package(url: "https://github.com/QMUI/LookinServer.git", branch: "develop"),
    ],
    targets: [
        .executableTarget(
            name: "LookinCLI",
            dependencies: [],
            path: "Sources/LookinCLI"
        ),
    ]
)
