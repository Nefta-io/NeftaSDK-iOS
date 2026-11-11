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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.7.3/NeftaSDK.xcframework-4.7.3.zip",
            checksum: "ba4b7f99e2bb4766fc0eb1e54441d9d060eb5a7268c3becad4d950f17170fd7a"
        )
    ]
)
