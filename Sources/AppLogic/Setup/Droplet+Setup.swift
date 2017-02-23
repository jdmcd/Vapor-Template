import Vapor
import HTTP
import VaporMySQL
import Fluent
import TurnstileCrypto
import Flash

public func load(_ drop: Droplet) throws {
    drop.preparations.append(User.self)
    drop.preparations.append(Session.self)
    try drop.addProvider(VaporMySQL.Provider)
    drop.middleware.append(FlashMiddleware())
    
    try loadViews(drop)
    try loadRoutes(drop)
}

//Function to setup routes
fileprivate func loadRoutes(_ drop: Droplet) throws {
    drop.grouped("api").group("v1") { grouped in
        
        //group these under required authentication middleware
        grouped.group(APIProtection()) { authed in
            authed.resource("user", UserController())
            grouped.group("user") { userGrouped in
                userGrouped.get("logout") { req in
                    let user = try req.APIUser()
                    return try user.logoutAPI()
                }
            }
        }
        
        //login and register functions do not need authentication
        grouped.group("user") { userGrouped in
            userGrouped.post("register") { req in
                guard let json = req.json else { throw Abort.badRequest }
                return try User.registerAPI(data: json.makeNode())
            }
            
            userGrouped.post("login") { req in
                guard let json = req.json else { throw Abort.badRequest }
                return try User.loginAPI(data: json.makeNode())
            }
        }
    }
}
