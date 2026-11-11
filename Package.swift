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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.19/NeftaSDK.xcframework-4.6.19.zip",
            checksum: "3d4d45b7b3fe70da2367abfc98fdd0d6b9378673196b1d17a606981a7d12be38"
        )
    ]
)
