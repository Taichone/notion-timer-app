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
            targets: ["Presentation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(url: "https://github.com/chojnac/NotionSwift.git", .upToNextMajor(from: "0.9.0")),
    ],
    targets: [
        .target(
            name: "Keychain",
            dependencies: []
        ),
        .target(
            name: "Notion",
            dependencies: [
                "Keychain",
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "NotionSwift", package: "NotionSwift")
            ]
        ),
        .target(
            name: "Presentation",
            dependencies: ["ScreenTime", "Notion", "Keychain", "Timer"],
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
            dependencies: ["ScreenTime"]
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
        .testTarget(
            name: "NotionTests",
            dependencies: ["Notion"]
        ),
    ]
)
