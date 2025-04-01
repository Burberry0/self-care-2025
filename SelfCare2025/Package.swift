// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SelfCare2025",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SelfCare2025",
            targets: ["SelfCare2025"]),
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .target(
            name: "SelfCare2025",
            dependencies: []),
        .testTarget(
            name: "SelfCare2025Tests",
            dependencies: ["SelfCare2025"]),
    ]
) 