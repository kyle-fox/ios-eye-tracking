// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EyeTracking",
    platforms: [.iOS(.v13)],
    products: [.library(name: "EyeTracking", targets: ["EyeTracking"])],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", from: "4.0.0"),
    ],
    targets: [
        .target(name: "EyeTracking", dependencies: ["GRDB"]),
        .testTarget(name: "ios-eye-trackingTests", dependencies: ["EyeTracking"], exclude: ["ios-eye-tracking-example"]),
    ],
    swiftLanguageVersions: [.v5]
)
