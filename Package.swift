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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.18/NeftaSDK.xcframework-4.6.18.zip",
            checksum: "8b25d17d0af5cf7374bc3b049be0595f33198a9b85c3060a891e5469c972e17b"
        )
    ]
)
