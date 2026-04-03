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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.5.0/NeftaSDK.xcframework-4.5.0.zip",
            checksum: "6a782faba264bc0226bacc53e104de69de6f9d6448bb2d3d64d9a93dc8538959"
        )
    ]
)
