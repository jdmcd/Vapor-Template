import Vapor
import Leaf
import Fluent
import Authentication

final class LoginViewController: RouteCollection {

    func boot(router: Router) throws {
        //TODO: - middleware
        router.get("/login", use: login)
        router.post("/login", use: loginPost)
        router.get("/logout", use: logout)
    }
    
    //MARK: - GET /login
    func login(_ req: Request) throws -> Future<View> {
        return try req.view().render("login", request: req)
    }
    
    //MARK: - POST /login
    func loginPost(_ req: Request) throws -> Future<Response> {
        //TODO: - Add flash here
        let invalidCredentialsResponse = req.redirect(to: "/login")
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        let query = User.query(on: req).filter(joined: \User.email == loginRequest.email).first()
        
        return query.map(to: Response.self) { user in
            guard let user = user else { return invalidCredentialsResponse }
            let hasher = try req.make(BCryptHasher.self)
            
            if try hasher.verify(message: loginRequest.password, matches: user.password) {
                //TODO: - authenticate
                try req.authenticate(user)
                return req.redirect(to: "/home")
            } else {
                return invalidCredentialsResponse
            }
        }
    }
    
    //MARK: - GET /logout
    func logout(_ req: Request) throws -> Response {
        return req.redirect(to: "/login")
    }
}

extension User: Authenticatable { }
