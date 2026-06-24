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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.0/NeftaSDK.xcframework-4.6.0.zip",
            checksum: "2d5a6997556bedbbfadaaf08357026cce296777d120d728e63b6c61d306deba5"
        )
    ]
)
