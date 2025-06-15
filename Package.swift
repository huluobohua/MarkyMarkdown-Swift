// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkyMarkdown",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "MarkyMarkdown",
            targets: ["MarkyMarkdown"]
        )
    ],
    dependencies: [
        // Markdown parsing
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.2.0"),
        
        // Syntax highlighting
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.2.0"),
        
        // HTTP client for AI services
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        
        // JSON parsing
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.3")
    ],
    targets: [
        .executableTarget(
            name: "MarkyMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Highlightr", package: "Highlightr"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/MarkyMarkdown"
        ),
        .testTarget(
            name: "MarkyMarkdownTests",
            dependencies: ["MarkyMarkdown"],
            path: "Tests/MarkyMarkdownTests"
        )
    ]
)