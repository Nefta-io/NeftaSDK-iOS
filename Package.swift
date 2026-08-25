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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.9/NeftaSDK.xcframework-4.6.9.zip",
            checksum: "ce42c69cfadcabeeef5ae2b7e029e39e441c2ebc324510780af367ce0877d5ec"
        )
    ]
)
