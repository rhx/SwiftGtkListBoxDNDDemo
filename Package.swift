// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "GtkListBoxDNDDemo",
    dependencies: [
        .package(name: "gir2swift", url: "https://github.com/rhx/gir2swift.git", .branch("swift52")),
        .package(name: "Gtk", url: "https://github.com/rhx/SwiftGtk.git", .branch("swift52")),
    ],
    targets: [
        .target(name: "GtkListBoxDNDDemo", dependencies: ["Gtk"]),
    ]
)
