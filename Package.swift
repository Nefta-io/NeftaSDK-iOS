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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.6/NeftaSDK.xcframework-4.6.6.zip",
            checksum: "720399779e46c3ab105179431501d1ec0fb3cc28f73cd7c4ce5f8f811e6be0b9"
        )
    ]
)
