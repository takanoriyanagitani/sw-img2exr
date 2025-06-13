// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "ImgToExrApi",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [
    .package(path: "../../.."),
    .package(url: "https://github.com/realm/SwiftLint", from: "0.59.1"),
    .package(
      url: "https://github.com/apple/swift-async-algorithms", from: "1.0.4"
    ),
    .package(
      url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0",
    ),
  ],
  targets: [
    .executableTarget(
      name: "ImgToExrApi",
      dependencies: [
        .product(name: "ImageToExr", package: "sw-img2exr"),
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
      ],
      swiftSettings: [
        .unsafeFlags(
          ["-cross-module-optimization"],
          .when(configuration: .release),
        )
      ],
    )
  ]
)
