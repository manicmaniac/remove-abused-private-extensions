// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "remove-abused-private-extensions",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50700.1"),
    ],
    targets: [
        .executableTarget(
            name: "remove-abused-private-extensions",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]),
        .testTarget(
            name: "remove-abused-private-extensions-tests",
            dependencies: [
                "remove-abused-private-extensions",
            ]
        )
    ]
)
