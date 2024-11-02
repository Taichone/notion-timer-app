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
            targets: ["Root", "Record"]
        ),
    ],
    targets: [
        .target(
            name: "Home",
            dependencies: ["TimerSetting", "Common", "Notion"]
        ),
        .target(
            name: "Notion",
            dependencies: ["Common"]
        ),
        .target(
            name: "Record",
            dependencies: [],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "Root",
            dependencies: ["Home", "Record", "Common"]
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
            dependencies: ["Record"]
        ),
        .target(
            name: "Common",
            dependencies: []
        ),
        .target(
            name: "TimerSetting",
            dependencies: ["ScreenTime", "Timer", "Record"],
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
