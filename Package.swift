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
    targets: [
        .target(
            name: "SwiftUIToast"
        ),
        .testTarget(
            name: "SwiftUIToastTests",
            dependencies: ["SwiftUIToast"]
        )
    ],
    swiftLanguageModes: [.v5]
)
