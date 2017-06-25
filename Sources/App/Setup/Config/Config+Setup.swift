import FluentProvider
import MySQLProvider
import RedisProvider
import Vapor
import Sessions
import AuthProvider
import LeafProvider
import Cookies

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        setupPreparations()
        try setupMiddleware()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(RedisProvider.Provider(config: self))
        try addProvider(AuthProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }
    
    private func setupMiddleware() throws {
        //redis
        guard let config = self["redis"] else { throw Abort.badRequest }
        guard let url = config["url"]?.string else { throw Abort.badRequest }
        let uri = URIParser().parse(bytes: url.bytes)
        let redisCache = try RedisCache(hostname: uri.hostname, port: uri.port ?? 6379, password: uri.userInfo?.info)
        
        let redisSessions = SessionsMiddleware(CacheSessions(redisCache)) { req -> Cookie in
            return Cookie(
                name: "vapor-session",
                value: "",
                expires: Date().addingTimeInterval(60 * 60 * 24 * 7), // 7 days
                secure: false,
                httpOnly: true
            )
        }
        
        addConfigurable(middleware: redisSessions, name: "redis")
    }
}
