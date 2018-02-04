// swift-tools-version:4.0

//
//  Astral
//  Copyright (c) 2017-2018 Julio Miguel Alorro
//  Licensed under the MIT license. See LICENSE file
//

import PackageDescription

let package = Package(
    name: "Astral",
    products: [
        .library(
            name: "Astral",
            targets: ["Astral"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Thomvis/BrightFutures", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "Astral",
            dependencies: ["BrightFutures"],
            path: "Sources"
        ),
        .testTarget(
            name: "AstralTests",
            dependencies: ["Astral"],
            path: "Tests"
        )
    ]
)
