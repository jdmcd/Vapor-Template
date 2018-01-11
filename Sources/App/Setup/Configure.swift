import Service
import Routing
import Vapor
import Fluent
import Foundation
import FluentMySQL
import Leaf
import Authentication

public func configure(_ config: inout Config, _ env: Environment, _ services: inout Services) throws {
    
    //MARK: - Heroku
    services.register(EngineServerConfig.heroku())
    
    //MARK: - Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: TemplateRenderer.self)

    //MARK: - CommonViewContext
    try services.register(CommonViewContextProvider())
    
    //MARK: - Authentication
    try services.register(AuthenticationProvider())

    //MARK: - Directory Config
    let directoryConfig = DirectoryConfig.default()
    services.register(directoryConfig)
    
    //MARK: - Fluent/MySQL
    try services.register(FluentMySQLProvider())
    var databaseConfig = DatabaseConfig()
    
    let username = "root"
    let database = "helloalpha4"
    
    let db = MySQLDatabase(hostname: "localhost", user: username, password: nil, database: database)
    databaseConfig.add(database: db, as: .mysql)
    services.register(databaseConfig)
    
    //MARK: - Migrations
    var migrationConfig = MigrationConfig()
    migrate(&migrationConfig)
    services.register(migrationConfig)
    
    //MARK: - Middleware
    let middlewareConfig = MiddlewareConfig.default()
    services.register(middlewareConfig)

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
