import Vapor
import HTTP
import VaporMySQL
import Fluent
import TurnstileCrypto

public func load(_ drop: Droplet) throws {
    drop.preparations.append(User.self)
    drop.preparations.append(Session.self)
    try drop.addProvider(VaporMySQL.Provider)
    
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
                return try User.registerAPI(req: req)
            }
            
            userGrouped.post("login") { req in
                return try User.loginAPI(req: req)
            }
        }
    }
}
