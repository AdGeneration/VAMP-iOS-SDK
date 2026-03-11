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
            exact: "3.3.0")
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
            url: "https://github.com/AdGeneration/VAMP-iOS-SDK/releases/download/5.3.5/VAMP-v5.3.5.zip",
            checksum: "c889bda8d19bdd5ae23489c5b7f465a6d16ddec9f79df3b2424f0c79adbfd410"),
    ]
)
