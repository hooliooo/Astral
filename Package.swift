// swift-tools-version:5.6

//
//  Astral
//  Copyright (c) Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import PackageDescription

let package = Package( // swiftlint:disable:this explicit_acl explicit_top_level_acl multiline_arguments_brackets
  name: "Astral",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(name: "Astral",targets: ["Astral"]),
    .library(name: "AstralOAuth", targets: ["OAuth"])
  ],
  dependencies: [
  ],
  targets: [
    .target(
      name: "Astral"
    ),
    .target(
      name: "OAuth",
      dependencies: [
        "Astral"
      ]
    ),
    .testTarget(
      name: "Tests",
      dependencies: ["Astral", "OAuth"],
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
