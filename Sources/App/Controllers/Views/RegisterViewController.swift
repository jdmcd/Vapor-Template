import Vapor
import Leaf
import Fluent
import Authentication

final class RegisterViewController: RouteCollection {
    
    func boot(router: Router) throws {
        //TODO: - middleware
        router.get("register", use: register)
        router.post("register", use: registerPost)
    }
    
    func register(_ req: Request) throws -> Future<View> {
        return try req.view().render("register", request: req)
    }
    
    func registerPost(_ req: Request) throws -> Future<Response> {
        //TODO: - Flash
        let registerRequest = try req.content.decode(RegisterViewRequest.self)
        
        if registerRequest.password != registerRequest.confirmPassword {
            return Future(req.redirect(to: "/register"))
        }
        
        let userQuery = User.query(on: req).filter(\.email == registerRequest.email).count()
        return userQuery.map(to: Response.self) { count in
            guard count == 0 else { return req.redirect(to: "/register") }
         
            let hasher = try req.make(BCryptHasher.self)
            let hashedPassword = try hasher.make(registerRequest.password)
            
            let newUser = User(name: registerRequest.name, email: registerRequest.email, password: hashedPassword)
            let _ = newUser.save(on: req)
            
            try req.authenticate(newUser)
            return req.redirect(to: "/home")
        }
    }
}

