// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NeftaSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NeftaSDK",
            targets: ["NeftaSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "NeftaSDK",
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.5.3/NeftaSDK.xcframework-4.5.3.zip",
            checksum: "81279a1f3992f0b4e45f6c3fa45609863e92c88cd96d6a293c9b5a41cf3ba28b"
        )
    ]
)
