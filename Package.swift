// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftXMLKit",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftXMLKit",
            targets: ["SwiftXMLKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftXMLKit",
            path: "SwiftXMLKit",
            sources: ["Sources"]
        )
    ],
    cxxLanguageStandard: .cxx14
) 
