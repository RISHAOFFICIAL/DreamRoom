// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DreamRoom",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DreamRoom",
            targets: ["DreamRoom"]),
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift.git", from: "16.0.0"),
    ],
    targets: [
        .target(
            name: "DreamRoom",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "DreamRoom"
        ),
        .testTarget(
            name: "DreamRoomTests",
            dependencies: ["DreamRoom"],
            path: "DreamRoomTests"
        ),
    ]
)
