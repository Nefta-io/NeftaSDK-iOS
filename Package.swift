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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.12/NeftaSDK.xcframework-4.6.12.zip",
            checksum: "19776ea9ab7ab14e9f83d6daa70b61c2b55bb5bd2f5b5e00c7de08f5a2745f02"
        )
    ]
)
