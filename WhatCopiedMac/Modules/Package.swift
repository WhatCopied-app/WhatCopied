// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Modules",
  platforms: [
    .macOS(.v26),
  ],
  products: [
    .library(
      name: "AppKitControls",
      targets: ["AppKitControls"]
    ),
    .library(
      name: "AppKitExtensions",
      targets: ["AppKitExtensions"]
    ),
    .library(
      name: "FoundationExtensions",
      targets: ["FoundationExtensions"]
    ),
  ],
  dependencies: [
    .package(path: "../../WhatCopiedTools"),
  ],
  targets: [
    .target(
      name: "AppKitControls",
      dependencies: [
        .target(name: "AppKitExtensions"),
      ],
      path: "Sources/AppKitControls",
      resources: [
        .process("Resources"),
      ],
      plugins: [
        .plugin(name: "SwiftLint", package: "WhatCopiedTools"),
      ]
    ),
    .target(
      name: "AppKitExtensions",
      path: "Sources/AppKitExtensions",
      plugins: [
        .plugin(name: "SwiftLint", package: "WhatCopiedTools"),
      ]
    ),
    .target(
      name: "FoundationExtensions",
      path: "Sources/FoundationExtensions",
      plugins: [
        .plugin(name: "SwiftLint", package: "WhatCopiedTools"),
      ]
    ),
  ]
)
