// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VAMP-iOS-SDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "VAMP",
            targets: ["VAMPTarget"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/AdGeneration/ADG-SSCore-iOS.git",
            exact: "3.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "VAMPTarget",
            dependencies: [
                .target(name: "VAMP"),
                .product(name: "SSCore", package: "ADG-SSCore-iOS")
            ],
            path: "VAMPTarget",
            linkerSettings: [
                .linkedFramework("VAMP"),
                // "The package product 'VAMP' cannot be used as a dependency of this target because it uses unsafe build flags."
                // .unsafeFlags(["-ObjC"])
            ]
        ),
        .binaryTarget(
            name: "VAMP",
            url: "https://github.com/AdGeneration/VAMP-iOS-SDK/releases/download/5.3.7/VAMP-v5.3.7.zip",
            checksum: "31b1e31b89a01fe5b8f42277d88327c606121166ee10ec7cad544a5fd7ed0fac"),
    ]
)
