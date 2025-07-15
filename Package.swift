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
            "0.2.2"..<"1.0.0")
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
            url: "https://d2dylwb3shzel1.cloudfront.net/iOS/VAMP-v5.3.3.zip",
            checksum: "ff3c0f679fe3b4da9b2f77882cddfbfebe98ef295d2bf91eb9cc2b7a2011e52d"),
    ]
)
