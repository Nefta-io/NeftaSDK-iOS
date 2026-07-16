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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.2/NeftaSDK.xcframework-4.6.2.zip",
            checksum: "a8f1d4547c2f90f2a33854254de6ed2f9dee8c79573ac193a15a804479f2cd96"
        )
    ]
)
