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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.8/NeftaSDK.xcframework-4.6.8.zip",
            checksum: "a15bfd7ec63b70266106ab12a8700bcabebf0adfb8dd4e585981dbadecc2c6ef"
        )
    ]
)
