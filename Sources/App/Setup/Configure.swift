import Service
import Routing
import Vapor
import Fluent
import Foundation
import FluentMySQL
import Leaf

public func configure(_ config: Config, _ env: Environment, _ services: inout Services) throws {
    try services.register(LeafProvider())
    
    let directoryConfig = DirectoryConfig.default()
    services.use(directoryConfig)
    
    try services.register(FluentProvider())
    services.use(FluentMySQLConfig())
    
    var databaseConfig = DatabaseConfig()
    
    let username = "root"
    let database = "helloalpha4"
    
    let db = MySQLDatabase(hostname: "localhost", user: username, password: nil, database: database)
    databaseConfig.add(database: db, as: .mysql)
    services.use(databaseConfig)
    
    var migrationConfig = MigrationConfig()
    migrate(&migrationConfig)
    services.use(migrationConfig)
    
    let middlewareConfig = MiddlewareConfig.default()
    services.use(middlewareConfig)

    //TODO: - redis and sessions
//    let redisCache = try RedisCache(config: self)
//    let redisSessions = SessionsMiddleware(CacheSessions(redisCache)) { req -> Cookie in
//        return Cookie(
//            name: "vapor-session",
//            value: "",
//            expires: Date().addingTimeInterval(60 * 60 * 24 * 7), // 7 days
//            secure: false,
//            httpOnly: true,
//            sameSite: .lax
//        )
//    }
//
//    addConfigurable(middleware: redisSessions, name: "redis")
    
    //TODO: - Tags
//    if let viewRenderer = view as? LeafRenderer {
//        viewRenderer.stem.register(IfValueIsLessThan())
//        viewRenderer.stem.register(IfValueIsGreaterThan())
//    }
}

func migrate(_ migrationConfig: inout MigrationConfig) {
    migrationConfig.add(model: User.self, database: .mysql)
    migrationConfig.add(model: Token.self, database: .mysql)
}

extension DatabaseIdentifier {
    static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
    }
}

