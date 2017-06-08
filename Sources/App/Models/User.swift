import Vapor
import FluentProvider
import AuthProvider
import Validation

final class User: Model {
    var storage = Storage()
    
    var name: String
    var email: String
    var password: String
    var admin: Bool
    
    init(name: String, email: String, password: String, admin: Bool = false) throws {
        self.name = name
        self.email = try email.tested(by: EmailValidator())
        self.password = password
        self.admin = admin
    }
    
    init(row: Row) throws {
        name = try row.get("name")
        
        let email: String = try row.get("email")
        self.email = try email.tested(by: EmailValidator())
        
        password = try row.get("password")
        admin = try row.get("admin") ?? false
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("name", name)
        try row.set("email", email)
        try row.set("password", password)
        try row.set("admin", admin)
        
        return row
    }
    
    init(json: JSON) throws {
        name = try json.get("name")
        
        let email: String = try json.get("email")
        self.email = try email.tested(by: EmailValidator())
        
        password = try json.get("password")
        admin = try json.get("admin") ?? false
    }
}

//MARK: - JSONConvertible
extension User: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("id", id)
        try json.set("name", name)
        try json.set("email", email)
        try json.set("admin", admin)
        try json.set("createdAt", updatedAt)
        try json.set("updatedAt", createdAt)
        try json.set("token", try token()?.token)
        
        return json
    }
}

//MARK: - Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string("name")
            builder.string("email", unique: true)
            builder.string("password")
            builder.bool("admin")
        })
    }
    
    static func revert(_ database: Database) throws {
        
    }
}

//MARK: - token()
extension User {
    func token() throws -> Token? {
        return try children(type: Token.self, foreignIdKey: "user_id").first()
    }
}

//MARK: - TokenAuthenticatable
extension User: TokenAuthenticatable {
    public typealias TokenType = Token
}

//MARK: - Request User Method
extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

//MARK: - SessionPersistable
extension User: SessionPersistable { }

//MARK: - Timestampable
extension User: Timestampable { }

//MARK: - UserContext
struct UserContext: Context {
    var token: String
}

//MARK: - Authenticate/UnAuthenticate
extension User {
    func authenticate(req: Request) throws {
        try req.auth.authenticate(self, persist: true)
        try setSession(req: req)
    }
    
    private func setSession(req: Request) throws {
        try req.assertSession().data["user"] = self.makeJSON().makeNode(in: nil)
    }
    
    func unauthenticate(req: Request) throws {
        try req.auth.unauthenticate()
        try req.assertSession().destroy()
    }
}
