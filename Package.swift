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
            url: "https://github.com/Nefta-io/NeftaSDK-iOS/releases/download/REL_4.6.17/NeftaSDK.xcframework-4.6.17.zip",
            checksum: "0412c794cc421997239fb04aabadaa3a52698384161d22c76d53debdc18c043b"
        )
    ]
)
