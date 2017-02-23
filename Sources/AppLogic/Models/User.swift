import Foundation
import Fluent
import Vapor
import Turnstile
import TurnstileCrypto
import TurnstileWeb
import HTTP

final class User: Model {
    var id: Node?
    var name: String
    var email: String
    var password: String
    var admin: Bool
    
    var exists: Bool = false
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = BCrypt.hash(password: password)
        self.admin = false
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.name = try node.extract("name")
        self.email = try node.extract("email")
        self.password = try node.extract("password")
        self.admin = false
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "password": password,
            "admin": admin
            ])
    }
    
    func makeJSON() throws -> JSON {
        return JSON(["name": .string(name), "email": .string(email)])
    }
    
    
    /// Set Session
    ///
    /// - Parameters:
    ///   - json: json
    ///   - req: the Request object
    /// - Returns: returns a Bool on whether or not it was successful
    /// - Throws: An Abort Error
    static func setSession(json: JSON, req: Request) throws -> Bool {
        guard let secret = json["secret"]?.string else { throw Abort.badRequest }
        guard let token = json["token"]?.string else { throw Abort.badRequest }
        
        try req.session().data["sessionToken"] = Node.string(token)
        try req.session().data["sessionSecret"] = Node.string(secret)
        try req.session().data["user"] = try req.user()?.makeNode()
        
        return true
    }
    
    /// Login from the API
    ///
    /// - Parameter data: A Node with the req data
    /// - Returns: A `Response` with detailed JSON on the result
    /// - Throws: An Abort Error
    static func loginAPI(data: Node) throws -> Response {
        guard let email = data["email"]?.string else { throw Abort.custom(status: .badRequest, message: "'email' must be included") }
        guard let submittedPassword = data["password"]?.string else { throw Abort.custom(status: .badRequest, message: "'password' must be included") }
        
        let fetchedUser = try User.query() .filter("email", email).first()
        let id = fetchedUser?.id?.int!
        
        if let password = fetchedUser?.password, password != "", (try? BCrypt.verify(password: submittedPassword, matchesHash: password)) == true {
            //they passed verification
            
            //see if a session already exists
            if let fetchedSession = try Session.query().filter("user_id", id!).first() {
                return try Response(status: .ok, json: JSON(["token": fetchedSession.token.makeNode(), "secret": fetchedSession.secret.makeNode()]))
            } else {
                
                var newSession = Session(user: id!)
                try newSession.save()
                
                return try Response(status: .ok, json: JSON(["token": newSession.token.makeNode(), "secret": newSession.secret.makeNode()]))
            }
            
        } else {
            return try Response(status: .unauthorized, json: JSON(["error":true, "message": "Invalid credentials"]))
        }
    }
    
    
    /// Login from the frontend
    ///
    /// - Parameters:
    ///   - data: A Node with the req data
    ///   - req: The request object
    /// - Returns: A `Response` that redirects the user
    /// - Throws: An Abort Error
    static func loginFrontend(data: Node, req: Request) throws -> Response {
        let apiLoginResponse = try loginAPI(data: data)
        if apiLoginResponse.status == .ok {
            guard let token = apiLoginResponse.json?["token"]?.string else { throw Abort.badRequest }
            guard let secret = apiLoginResponse.json?["secret"]?.string else { throw Abort.badRequest }
            
            try req.session().data["sessionToken"] = token.makeNode()
            try req.session().data["sessionSecret"] = secret.makeNode()
            
            return Response(redirect: "home").flash(.success, "Successfully logged in")
        } else if apiLoginResponse.status == .unauthorized {
            return Response(redirect: "login").flash(.error, "Invalid Credentials")
        } else {
            return Response(redirect: "login").flash(.error, "Something went wrong")
        }
    }
    
    /// Register a new user from the API
    ///
    /// - Parameter data: A Node with the req data
    /// - Returns: A `Response` with detailed JSON on the result
    /// - Throws: An Abort Error
    static func registerAPI(data: Node) throws -> Response {
        guard let name = data["name"]?.string else { throw Abort.custom(status: .badRequest, message: "'name' must be included") }
        guard let email = data["email"]?.string else { throw Abort.custom(status: .badRequest, message: "'email' must be included") }
        guard let password = data["password"]?.string else { throw Abort.custom(status: .badRequest, message: "'password' must be included") }
        
        let usersReturned = try User.query().filter("email", email).all()
        if usersReturned.isEmpty {
            var user = User(name: name, email: email, password: password)
            try user.save()
            
            var newSession = Session(user: user.id!.int!)
            try newSession.save()
            
            let json = JSON(["name": .string(name), "email": .string(email), "token": .string(newSession.token), "secret": .string(newSession.secret)])
            return try Response(status: .ok, json: json)
        } else {
            throw Abort.custom(status: .badRequest, message: "Email is already registered")
        }
    }
    
    static func registerFromView(req: Request) throws -> Response {
        guard let form = req.formURLEncoded else { throw Abort.badRequest }
        guard let name = form["name"]?.string else { throw Abort.badRequest }
        guard let email = form["email"]?.string else { throw Abort.badRequest }
        guard let password = form["password"]?.string else { throw Abort.badRequest }
        guard let confirmPassword = form["confirm_password"]?.string else { throw Abort.badRequest }
        
        if password != confirmPassword {
            return Response(redirect: "register").flash(.error, "Passwords don't match")
        }
        
        let json = JSON(["name": name.makeNode(), "email": email.makeNode(), "password": password.makeNode()])
        
        do {
            let registerResult = try User.registerAPI(data: json.makeNode())
            let sessionResult = try User.setSession(json: registerResult.json!, req: req)
            if sessionResult {
                return Response(redirect: "home")
            } else {
                return Response(redirect: "register").flash(.error, "Something went wrong. Please try again")
            }
        } catch {
            return Response(redirect: "register").flash(.error, "Email is taken")
        }
    }
    
    /// Logouts the user from the API
    ///
    /// - Returns: A response with JSON
    /// - Throws: An Abort Error
    func logoutAPI() throws -> Response {
        try Session.query().filter("user_id", id!).delete()
        return try Response(status: .accepted, json: JSON(["success":true]))
    }
    
    
    /// Logouts the user from the frontend
    ///
    /// - Returns: A `Response` to redirect the user
    /// - Throws: An Abort Error
    func logoutFrontend(req: Request) throws -> Response {
        try Session.query().filter("user_id", id!.int!).delete()
        try req.session().destroy()
        return Response(redirect: "/").flash(.success, "Successfully Logged Out")
    }
}

//MARK: - Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users", closure: { users in
            users.id()
            users.string("name", length: 255, optional: false)
            users.string("email", length: 255, optional: false)
            users.string("password", length: 255, optional: false)
            users.bool("admin")
        })
    }
    
    static func revert(_ database: Database) throws {
    }
}
