// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SelfCare",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SelfCareKit",
            targets: ["SelfCareKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SelfCareKit",
            dependencies: ["Core", "Habits", "Mood", "Health", "User", "Recommendations"],
            path: "Sources/SelfCareKit"
        ),
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"
        ),
        .target(
            name: "Habits",
            dependencies: ["Core"],
            path: "Sources/Habits"
        ),
        .target(
            name: "Mood",
            dependencies: ["Core"],
            path: "Sources/Mood"
        ),
        .target(
            name: "Health",
            dependencies: ["Core"],
            path: "Sources/Health"
        ),
        .target(
            name: "User",
            dependencies: ["Core"],
            path: "Sources/User"
        ),
        .target(
            name: "Recommendations",
            dependencies: ["Core", "User"],
            path: "Sources/Recommendations"
        ),
        .testTarget(
            name: "SelfCareTests",
            dependencies: ["SelfCareKit"],
            path: "Tests/SelfCareTests"
        )
    ]
) 