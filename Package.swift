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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.5.7/NeftaSDK.xcframework-4.5.7.zip",
            checksum: "5446aa84a8b70b4923c6ad9478418053f1c074ac51de987a63594ea271b35e09"
        )
    ]
)
