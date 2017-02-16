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
    
    var exists: Bool = false
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = BCrypt.hash(password: password)
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.name = try node.extract("name")
        self.email = try node.extract("email")
        self.password = try node.extract("password")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "password": password
            ])
    }
    
    func makeJSON() throws -> JSON {
        return JSON(["name": .string(name), "email": .string(email)])
    }
    
    
    /// Login from the API
    ///
    /// - Parameter req: A `Request` from the call
    /// - Returns: A `Response` with detailed JSON on the result
    /// - Throws: An Abort Error
    static func loginAPI(req: Request) throws -> Response {
        let form = req.data
        guard let email = form["email"]?.string else { throw Abort.custom(status: .badRequest, message: "'email' must be included") }
        guard let submittedPassword = form["password"]?.string else { throw Abort.custom(status: .badRequest, message: "'password' must be included") }
        
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
    
    
    /// Register a new user from the API
    ///
    /// - Parameter req: A `Request` from the call
    /// - Returns: A `Response` with detailed JSON on the result
    /// - Throws: An Abort Error
    static func registerAPI(req: Request) throws -> Response {
        let json = req.data
        
        guard let name = json["name"]?.string else { throw Abort.custom(status: .badRequest, message: "'name' must be included") }
        guard let email = json["email"]?.string else { throw Abort.custom(status: .badRequest, message: "'email' must be included") }
        guard let password = json["password"]?.string else { throw Abort.custom(status: .badRequest, message: "'password' must be included") }
        
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
    
    
    /// Logouts the user from the API
    ///
    /// - Returns: A response with JSON
    /// - Throws: An Abort Error
    func logoutAPI() throws -> Response {
        try Session.query().filter("user_id", id!).delete()
        return try Response(status: .accepted, json: JSON(["success":true]))
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
        })
    }
    
    static func revert(_ database: Database) throws {
    }
}
