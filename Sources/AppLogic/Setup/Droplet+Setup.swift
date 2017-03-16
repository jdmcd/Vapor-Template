import Vapor
import HTTP
import VaporMySQL
import Fluent
import TurnstileCrypto
import Flash
import VaporRedis
import Sessions
import VaporSecurityHeaders

public func load(_ drop: Droplet) throws {
    let securityHeaders = SecurityHeaders()
    drop.middleware.append(securityHeaders)
    
    drop.preparations.append(User.self)

    try drop.addProvider(VaporMySQL.Provider)
    try drop.addProvider(VaporRedis.Provider(config: drop.config))
    drop.middleware.append(SessionsMiddleware(sessions: CacheSessions(cache: drop.cache)))
    drop.middleware.append(FlashMiddleware())
    
    if let leaf = drop.view as? LeafRenderer {
        if drop.environment != .production {
            leaf.stem.cache = nil
        }
        leaf.stem.register(IfValueIsLessThan())
        leaf.stem.register(IfValueIsGreaterThan())
    }
    
    
    
    try loadViews(drop)
    try loadRoutes(drop)
}

//Function to setup routes
fileprivate func loadRoutes(_ drop: Droplet) throws {
    drop.grouped("api").group("v1") { grouped in
        //group these under required authentication middleware
        grouped.grouped(APIAuthed()).group("user") { authed in
            authed.resource("/", UserController())
            authed.get("logout") { req in
                let user = try req.APIUser()
                return try user.logout(req: req)
            }
        }
        
        //login and register functions do not need authentication
        grouped.group("user") { userGrouped in
            userGrouped.post("register") { req in
                if let _ = try req.user() {
                    return try Response(status: .badRequest, json: JSON(["error": true, "message": "You are signed in already"]))
                }
                
                guard let json = req.json else { throw Abort.badRequest }
                return try User.registerAPI(data: json.makeNode(), req: req)
            }
            
            userGrouped.post("login") { req in
                guard let json = req.json else { throw Abort.badRequest }
                return try User.loginAPI(data: json.makeNode(), req: req)
            }
        }
    }
}
