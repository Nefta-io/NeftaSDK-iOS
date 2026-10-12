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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.7.0/NeftaSDK.xcframework-4.7.0.zip",
            checksum: "708096256e4e4f56f18963f255606fc96bd111b4ad17164b6e489abc5571bcd2"
        )
    ]
)
