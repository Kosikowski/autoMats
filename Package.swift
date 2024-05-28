// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "autoMats",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "autoMats",
            targets: ["autoMats"]
        ),
        .executable(
            name: "amc",
            targets: ["amc"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // Macro implementation that performs the source transformation of a macro.
        .macro(
            name: "autoMatsMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(name: "autoMats", dependencies: ["autoMatsMacros"], swiftSettings: [.enableExperimentalFeature("BodyMacros")]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "amc", dependencies: [
            "autoMats",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "autoMatsTests",
            dependencies: [
                "autoMatsMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
