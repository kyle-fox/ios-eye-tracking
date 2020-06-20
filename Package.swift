// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-eye-tracking",
    platforms: [.iOS(.v11)],
    products: [.library(name: "ios-eye-tracking", targets: ["ios-eye-tracking"])],
    targets: [
        .target(name: "ios-eye-tracking", dependencies: [], exclude: ["ios-eye-tracking-example"]),
        .testTarget(name: "ios-eye-trackingTests",dependencies: ["ios-eye-tracking"], exclude: ["ios-eye-tracking-example"]),
    ],
    swiftLanguageVersions: [.v5]
)
