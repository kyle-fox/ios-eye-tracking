// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EyeTracking",
    platforms: [.iOS(.v13)],
    products: [.library(name: "EyeTracking", targets: ["EyeTracking"])],
    targets: [
        .target(name: "EyeTracking", dependencies: []),
        .testTarget(name: "ios-eye-trackingTests",dependencies: ["EyeTracking"]),
    ],
    swiftLanguageVersions: [.v5]
)
