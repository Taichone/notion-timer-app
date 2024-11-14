// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NotionTimerPackage",
    defaultLocalization: "ja",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "NotionTimerPackage",
            targets: ["Root"]
        ),
    ],
    targets: [
        .target(
            name: "Common",
            dependencies: []
        ),
        .target(
            name: "LocalRepository",
            dependencies: []
        ),
        .target(
            name: "Notion",
            dependencies: ["LocalRepository"]
        ),
        .target(
            name: "Root",
            dependencies: ["LocalRepository", "Notion", "TimerSetting", "Common"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "ScreenTime",
            dependencies: []
        ),
        .target(
            name: "Timer",
            dependencies: ["ScreenTime", "TimerRecord", "Common"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "TimerRecord",
            dependencies: []
        ),
        .target(
            name: "TimerSetting",
            dependencies: ["ScreenTime", "Timer"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "TimerTests",
            dependencies: ["Timer"]
        ),
    ]
)
