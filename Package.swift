import PackageDescription

let package = Package(
    name: "PROJECT_NAME",
    targets: [
        Target(name: "App", dependencies: ["AppLogic"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/nodes-vapor/flash.git", majorVersion: 0),
        .Package(url: "https://github.com/bygri/vapor-wkhtmltopdf", majorVersion: 0),
        .Package(url: "https://github.com/vapor/redis-provider", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/brokenhandsio/VaporSecurityHeaders", majorVersion: 0, minor: 3)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources"
    ]
)
