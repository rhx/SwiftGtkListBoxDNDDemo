// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "GtkListBoxDNDDemo",
    dependencies: [
        .package(url: "https://github.com/rhx/SwiftGtk.git", branch: "monorepo"),
    ],
    targets: [
        .target(name: "GtkListBoxDNDDemo", dependencies: [
            .product(name: "Gtk", package: "SwiftGtk"),
        ]),
    ]
)
