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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.13/NeftaSDK.xcframework-4.6.13.zip",
            checksum: "840c0bcca4bbb2cf83cdfdf64d227554b2e6aa2cba6297d99c31f657a97fdcba"
        )
    ]
)
