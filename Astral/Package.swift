// swift-tools-version:5.7

//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import PackageDescription

let package = Package( // swiftlint:disable:this explicit_acl explicit_top_level_acl multiline_arguments_brackets
  name: "Astral",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(name: "Astral",targets: ["Astral"]),
    .library(name: "OAuth2", targets: ["OAuth2"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "3.0.0")
  ],
  targets: [
    .target(
      name: "Astral"
    ),
    .target(
      name: "OAuth2",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto"),
        "Astral"
      ]
    ),
    .testTarget(
      name: "Tests",
      dependencies: [
        "Astral",
        "OAuth2"
      ],
      path: "Tests",
      exclude: [
        "Supporting Files/iOS/Info.plist",
        "Supporting Files/Mac/Info.plist",
      ],
      resources: [
        .copy("Supporting Files/pic1.png"),
        .copy("Supporting Files/pic2.png"),
        .copy("Supporting Files/pic3.png"),
      ]
    )
  ]
)
