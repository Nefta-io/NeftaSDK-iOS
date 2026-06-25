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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.1/NeftaSDK.xcframework-4.6.1.zip",
            checksum: "718e4866f7944af8f3a580c7858b4c2129c26bb0d745b033cc2f4932c7474640"
        )
    ]
)
