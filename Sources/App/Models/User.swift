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
        name = try row.get(Field.name)
        
        let email: String = try row.get(Field.email)
        self.email = try email.tested(by: EmailValidator())
        
        password = try row.get(Field.password)
        admin = try row.get(Field.admin) ?? false
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Field.name, name)
        try row.set(Field.email, email)
        try row.set(Field.password, password)
        try row.set(Field.admin, admin)
        
        return row
    }
    
    init(json: JSON) throws {
        name = try json.get(Field.name)
        
        let email: String = try json.get(Field.email)
        self.email = try email.tested(by: EmailValidator())
        
        password = try json.get(Field.password)
        admin = try json.get(Field.admin) ?? false
    }
}

//MARK: - JSONConvertible
extension User: JSONConvertible {
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Field.id, id)
        try json.set(Field.name, name)
        try json.set(Field.email, email)
        try json.set(Field.admin, admin)
        try json.set(User.createdAtKey, createdAt)
        try json.set(User.updatedAtKey, updatedAt)
        try json.set("token", try token()?.token)
        
        return json
    }
}

//MARK: - Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string(Field.name)
            builder.string(Field.email, unique: true)
            builder.string(Field.password)
            builder.bool(Field.admin)
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

//MARK: - Field
extension User {
    enum Field: String {
        case id
        case name
        case email
        case password
        case admin
    }
}
