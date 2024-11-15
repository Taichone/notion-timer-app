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
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0"))
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
            dependencies: [
                "LocalRepository",
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
        .target(
            name: "Root",
            dependencies: ["LocalRepository", "Notion", "Timer", "Common"],
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
            dependencies: ["ScreenTime", "Common"],
            resources: [
                .process("Resources/Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "TimerTests",
            dependencies: ["Timer"]
        ),
        .testTarget(
            name: "NotionTests",
            dependencies: ["Notion"]
        ),
    ]
)
