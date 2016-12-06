import PackageDescription

let package = Package(
    name: "Template",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 2),
        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 1)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources"
    ]
)

