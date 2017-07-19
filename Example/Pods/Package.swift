// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Astral",
    dependencies: [
        .Package(url: "https://github.com/Thomvis/BrightFutures", majorVersion: 5),
        .Package(url: "https://github.com/antitypical/Result.git", majorVersion: 3)
    ]
)
