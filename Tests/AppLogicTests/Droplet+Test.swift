@testable import Vapor
@testable import AppLogic

public func makeTestDroplet() throws -> Droplet {
    let testConfig = try Config(node: [
        "mysql": [
            "user": "admin",
            "password": "adminpass",
            "host": "localhost",
            "port": "3306",
            "database": "CHANGEDATABASEHERE"
        ]
        ])
    
    let drop = Droplet(arguments: ["dummy/path/", "prepare"], config: testConfig)
    try load(drop)
    try drop.runCommands()
    return drop
}
