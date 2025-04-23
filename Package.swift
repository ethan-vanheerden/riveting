// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Riveting",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Riveting",
            targets: ["Riveting"]
        ),
        .library(
            name: "RivetingTestSupport",
            targets: ["RivetingTestSupport"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Riveting",
            path: "Sources/Riveting"
        ),
        .target(
            name: "RivetingTestSupport",
            dependencies: ["Riveting"],
            path: "Sources/RivetingTestSupport"
        ),
        .testTarget(
            name: "RivetingTests",
            dependencies: ["Riveting"],
            path: "Tests/RivetingTests"
        ),
    ]
)
