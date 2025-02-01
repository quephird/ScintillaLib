// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScintillaLib",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
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
        .executableTarget(
            name: "StarPrism",
            dependencies: ["ScintillaLib"],
            path: "Examples/StarPrism"),
        .executableTarget(
            name: "Vase",
            dependencies: ["ScintillaLib"],
            path: "Examples/Vase"),
        .executableTarget(
            name: "RainbowBall",
            dependencies: ["ScintillaLib"],
            path: "Examples/RainbowBall"),
        .executableTarget(
            name: "HollowedSphere",
            dependencies: ["ScintillaLib"],
            path: "Examples/HollowedSphere"),
        .executableTarget(
            name: "BallWithAreaLight",
            dependencies: ["ScintillaLib"],
            path: "Examples/BallWithAreaLight"),
        .executableTarget(
            name: "HappyHalloween",
            dependencies: ["ScintillaLib"],
            path: "Examples/HappyHalloween"),
        .executableTarget(
            name: "TDOR",
            dependencies: ["ScintillaLib"],
            path: "Examples/TDOR"),
        .executableTarget(
            name: "Cavatappi",
            dependencies: ["ScintillaLib"],
            path: "Examples/Cavatappi"),
        .executableTarget(
            name: "Breather",
            dependencies: ["ScintillaLib"],
            path: "Examples/Breather"),
        .executableTarget(
            name: "Rings",
            dependencies: ["ScintillaLib"],
            path: "Examples/Rings"),
        .executableTarget(
            name: "Hourglass",
            dependencies: ["ScintillaLib"],
            path: "Examples/Hourglass"),
        .executableTarget(
            name: "DecoCube",
            dependencies: ["ScintillaLib"],
            path: "Examples/DecoCube"),
        .executableTarget(
            name: "DimlyLitScene",
            dependencies: ["ScintillaLib"],
            path: "Examples/DimlyLitScene"),
        .executableTarget(
            name: "FishEye",
            dependencies: ["ScintillaLib"],
            path: "Examples/FishEye"),
        .executableTarget(
            name: "Wine",
            dependencies: ["ScintillaLib"],
            path: "Examples/Wine"),
        .executableTarget(
            name: "TestDie",
            dependencies: ["ScintillaLib"],
            path: "Examples/TestDie"),
    ]
)
