// swift-tools-version:4.0

//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import PackageDescription

let package = Package( // swiftlint:disable:this explicit_acl explicit_top_level_acl multiline_arguments_brackets
    name: "Astral",
    products: [
        .library(
            name: "Astral",
            targets: ["Astral"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .testTarget(
            name: "AstralTests",
            dependencies: ["Astral"],
            path: "Tests"
        )
    ]
)
