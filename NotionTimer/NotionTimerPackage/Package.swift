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
            name: "Root",
            dependencies: ["TimerSetting", "ViewCommon"]
        ),
        .target(
            name: "Record",
            dependencies: []
        ),
        .target(
            name: "ScreenTime",
            dependencies: []
        ),
        .target(
            name: "Timer",
            dependencies: ["ScreenTime", "TimerRecord", "ViewCommon"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .target(
            name: "TimerRecord",
            dependencies: ["Record"]
        ),
        .target(
            name: "ViewCommon",
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
