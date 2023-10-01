// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScintillaLib",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ScintillaLib",
            targets: ["ScintillaLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Core library.
        .target(
            name: "ScintillaLib",
            dependencies: []),

        // Tests
        .testTarget(
            name: "ScintillaLibTests",
            dependencies: ["ScintillaLib"]),

        // Examples
        .executableTarget(
            name: "QuickStart",
            dependencies: ["ScintillaLib"],
            path: "Examples/QuickStart"),
        .executableTarget(
            name: "Die",
            dependencies: ["ScintillaLib"],
            path: "Examples/Die"),
        .executableTarget(
            name: "Blob",
            dependencies: ["ScintillaLib"],
            path: "Examples/Blob"),
        .executableTarget(
            name: "BarthSextic",
            dependencies: ["ScintillaLib"],
            path: "Examples/BarthSextic"),
        .executableTarget(
            name: "Superellipsoids",
            dependencies: ["ScintillaLib"],
            path: "Examples/Superellipsoids"),
    ]
)
