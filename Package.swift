// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "autoMats",
    platforms: [.macOS(.v14), .iOS(.v15), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
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
        .package(url: "https://github.com/apple/swift-syntax.git", "600.0.0" ..< "601.0.0"),
    ],

    targets: [
        .macro(
            name: "autoMatsMacros",
            dependencies: [
                "autoMatsUtils",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [] // .enableExperimentalFeature("AccessLevelOnImport"), .enableExperimentalFeature("InternalImportsByDefault")]
        ),

        .target(
            name: "autoMats",
            dependencies: ["autoMatsMacros"],
            swiftSettings: [] // .enableExperimentalFeature("AccessLevelOnImport")]
        ),

        .target(
            name: "autoMatsUtils",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: [] // .enableExperimentalFeature("AccessLevelOnImport")]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "amc", dependencies: [
            "autoMats",
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "autoMatsTests",
            dependencies: [
                "autoMats",
                "autoMatsMacros",
                "autoMatsUtils",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [] // .enableExperimentalFeature("AccessLevelOnImport")]
        ),
    ]
)
