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
            exact: "3.0.0")
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
            url: "https://d2dylwb3shzel1.cloudfront.net/iOS/VAMP-v5.3.4.zip",
            checksum: "5237827859d4a68581c5b8911ecd35c4cc811d169e993eb553031c2400aa02a2"),
    ]
)
