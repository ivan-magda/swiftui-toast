// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swiftui-toast",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "SwiftUIToast",
            targets: ["SwiftUIToast"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SwiftUIToast"
        ),
        .testTarget(
            name: "SwiftUIToastTests",
            dependencies: ["SwiftUIToast"]
        )
    ]
)
