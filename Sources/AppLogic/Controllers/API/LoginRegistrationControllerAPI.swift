import Vapor
import HTTP
import Auth

final class LoginRegistrationControllerAPI {
    private let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.grouped("api/v1").group("user") { grouped in
            //the authed routes - User controller, and the logout route
            grouped.group(AuthedMiddleware(isAPI: true)) { authed in
                authed.resource("/", UserController())
                authed.get("logout", handler: logout)
            }
            
            grouped.post("register", handler: register)
            grouped.post("login", handler: login)
        }
    }
    
    func register(_ req: Request) throws -> ResponseRepresentable {
        if let _ = req.auth.header?.bearer {
            throw Abort.custom(status: .badRequest, message: "You are signed in already")
        }
        
        guard let json = req.json else { throw Abort.badRequest }
        let credentials = try UserCredentials(json: json)
        
        guard var user = try User.register(credentials: credentials) as? User else { throw Abort.badRequest }
        try user.save()
        try user.setSession(req: req)
        
        var newToken = Token(user_id: user.id!.int!)
        try newToken.save()
        
        return try JSON(node: try user.makeNode(context: UserContext(token: newToken.token)))
    }
    
    func login(_ req: Request) throws -> ResponseRepresentable {
        if let _ = req.auth.header?.bearer {
            throw Abort.custom(status: .badRequest, message: "You are signed in already")
        }
        
        guard let json = req.json else { throw Abort.badRequest }
        let credentials = try UserLoginCredentials(json: json)
        guard let user = try User.authenticate(credentials: credentials) as? User else {
            throw Abort.badRequest
        }
        
        try user.setSession(req: req)
        
        let tokensAlreadyActive = try Token.query().filter("user_id", user.id!.int!).all()
        if tokensAlreadyActive.count != 0 {
            guard let first = tokensAlreadyActive.first else { throw Abort.badRequest }
            return try JSON(node: user.makeNode(context: UserContext(token: first.token)))
        }
        
        var newToken = Token(user_id: user.id!.int!)
        try newToken.save()
        
        return try JSON(node: user.makeNode(context: UserContext(token: newToken.token)))
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        guard let APIKey = req.auth.header?.bearer else { throw Abort.badRequest }
        try req.user().logout(req: req)
        try Token.query().filter("token", APIKey.string).delete()
        return try Response(status: .ok, json: JSON(["success":true]))
    }
}
