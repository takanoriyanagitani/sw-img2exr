// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "sw-img2exr",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(
      name: "ImageToExr",
      targets: ["ImageToExr"])
  ],
  dependencies: [
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1")
  ],
  targets: [
    .target(
      name: "ImageToExr"),
    .testTarget(
      name: "ImageToExrTests",
      dependencies: ["ImageToExr"]
    ),
  ]
)
