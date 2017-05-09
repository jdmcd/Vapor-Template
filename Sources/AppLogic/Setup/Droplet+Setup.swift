import Vapor
import Foundation
import HTTP
import VaporMySQL
import VaporRedis
import Sessions
import VaporSecurityHeaders
import Auth
import Cookies
import Flash

public func load(_ drop: Droplet) throws {
    //Flash and security middleware
    let securityHeaders = SecurityHeaders()
    drop.middleware.append(securityHeaders)
    drop.middleware.append(FlashMiddleware())
    
    //Register preparations
    registerPreparations(drop)
    
    
    //Providers
    try drop.addProvider(VaporMySQL.Provider)
    try drop.addProvider(VaporRedis.Provider(config: drop.config))
 

    //Redis setup
    guard let config = drop.config["redis"] else { throw Abort.badRequest }
    guard let url = config["url"]?.string else { throw Abort.badRequest }
    
    let uri = try URIParser.parse(bytes: url.bytes)
    let redisCache = try RedisCache(address: uri.host, port: uri.port ?? 6379, password: uri.userInfo?.info)
    
    drop.cache = redisCache
    
    let redisSessions = SessionsMiddleware(sessions: CacheSessions(cache: redisCache))
    if let index = drop.middleware.index(where: { $0 is SessionsMiddleware }) {
        drop.middleware[index] = redisSessions
    } else {
        drop.middleware.insert(redisSessions, at: 0)
    }
    
    
    //Leaf caching and tag setup
    if let leaf = drop.view as? LeafRenderer {
        if drop.environment != .production {
            leaf.stem.cache = nil
        }
        leaf.stem.register(IfValueIsLessThan())
        leaf.stem.register(IfValueIsGreaterThan())
    }
    
    
    //Auth Middleware
    let auth = AuthMiddleware(user: User.self, cache: redisCache, refreshCookieEveryRequest: true) { value in
        return Cookie(
            name: "vapor-auth",
            value: value,
            expires: Date().addingTimeInterval(60 * 60 * 24 * 7), // 7 days
            secure: false,
            httpOnly: true
        )
    }
    
    drop.middleware.append(auth)
    
    
    //Call upon other views and routes to register themselves
    try loadViews(drop)
    try loadRoutes(drop)
}
