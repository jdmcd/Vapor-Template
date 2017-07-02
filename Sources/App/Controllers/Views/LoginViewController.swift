import Vapor
import BCrypt
import Flash

final class LoginViewController: RouteCollection {
    private let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        builder.frontend(.noAuthed) { build in
        
            //Login
            build.group(RedirectMiddleware()) { redirect in
                redirect.get("/login", handler: login)
                redirect.post("/login", handler: handleLoginPost)
            }
            
            //Logout
            build.group(AuthedMiddleware()) { authed in
                authed.get("/logout", handler: logout)
            }
        }
    }
    
    //MARK: - GET /login
    func login(_ req: Request) throws -> ResponseRepresentable {
        print(try req.assertSession().identifier)
        return try view.make("login", for: req)
    }
    
    //MARK: - POST /login
    func handleLoginPost(_ req: Request) throws -> ResponseRepresentable {
        let invalidCredentialsResponse = Response(redirect: "/login").flash(.error, "Invalid Credentials")
        
        guard let data = req.formURLEncoded else { throw Abort.badRequest }
        
        //TODO: - Generic subscript upon Swift 4
        guard let email = data[User.Field.email.rawValue]?.string else { throw Abort.badRequest }
        guard let password = data[User.Field.password.rawValue]?.string else { throw Abort.badRequest }
        
        guard let user = try User.makeQuery().filter(User.Field.email, email).first() else {
            return invalidCredentialsResponse
        }
        
        if try BCryptHasher().verify(password: password, matches: user.password) {
            try user.authenticate(req: req)
            return Response(redirect: "/home")
        } else {
            return invalidCredentialsResponse
        }
    }
    
    //MARK: - GET /logout
    func logout(_ req: Request) throws -> ResponseRepresentable {
        try req.user().unauthenticate(req: req)
        return Response(redirect: "/login").flash(.success, "Logged Out")
    }
}
