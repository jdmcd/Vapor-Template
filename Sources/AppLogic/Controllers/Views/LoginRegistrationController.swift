import Vapor
import HTTP
import Auth
import Turnstile

final class LoginRegistrationController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group(RedirectMiddleware()) { redirect in
            redirect.get("login", handler: loginView)
            redirect.post("login", handler: login)
            redirect.get("register", handler: registerView)
            redirect.post("register", handler: register)
        }
        
        drop.group(AuthedMiddleware()) { authed in
            authed.get("logout", handler: logout)
            authed.get("home", handler: homeView)
        }
    }
    
    func loginView(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login", for: req)
    }
    
    func login(_ req: Request) throws -> ResponseRepresentable {
        guard let data = req.formURLEncoded else { throw Abort.badRequest }
        let credentials = try UserLoginCredentials(json: JSON(node: data))
        
        do {
            try req.auth.login(credentials, persist: true)
            guard let user = try req.auth.user() as? User else { throw Abort.serverError }
            try user.setSession(req: req)
            return Response(redirect: "home").flash(.success, "Logged in")
        } catch {
            return Response(redirect: "login").flash(.error, "Invalid Credentials")
        }
    }
    
    func registerView(_ req: Request) throws -> ResponseRepresentable {
        return try drop.view.make("register", for: req)
    }
    
    func register(_ req: Request) throws -> ResponseRepresentable {
        guard let data = req.formURLEncoded else { throw Abort.badRequest }
        let credentials = try UserCredentials(json: JSON(node: data))
        let loginCredentials = try UserLoginCredentials(json: JSON(node: data))
        
        do {
            guard var user = try User.register(credentials: credentials) as? User else { throw Abort.badRequest }
            try user.save()
            try user.setSession(req: req)
            
            try req.auth.login(loginCredentials, persist: true)
            return Response(redirect: "home").flash(.success, "Successfully registered")
        } catch RegistrationError.emailTaken {
            return Response(redirect: "register").flash(.error, "Email is already registered")
        } catch {
            return Response(redirect: "register").flash(.error, "Something went wrong")
        }
    }
    
    func logout(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.logout(req: req)
        return Response(redirect: "/").flash(.success, "Logged out")
    }
    
    func homeView(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
}
