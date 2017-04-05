import Vapor
import Fluent
import Auth
import BCrypt
import HTTP

final class User: Model {
    var id: Node?
    var name: String
    var email: String
    var password: String
    var admin: Bool
    
    var exists: Bool = false
    
    init(name: String, email: String, password: String, admin: Bool = false) {
        self.name = name
        self.email = email
        self.password = password
        self.admin = admin
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.name = try node.extract("name")
        self.email = try node.extract("email")
        self.password = try node.extract("password")
        self.admin = try node.extract("admin") ?? false
    }
    
    func makeNode(context: Context) throws -> Node {
        var node = try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "admin": admin
            ])
        
        switch context {
        case is UserContext:
            guard let userContext = context as? UserContext else { throw Abort.badRequest }
            node["token"] = userContext.token.makeNode()
        case is DatabaseContext:
            node["password"] = password.makeNode()
        default: ()
        }
        
        return node
    }
    
    func makeJSON() throws -> JSON {
        return JSON([
            "name": .string(name),
            "email": .string(email),
            "admin": .bool(admin)
            ])
    }
    
    func setSession(req: Request) throws {
        try req.session().data["user"] = makeNode(context: SessionContext())
    }
    
    func logout(req: Request) throws {
        try req.auth.logout()
        try req.session().destroy()
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
        
        let hashedPassword = try BCrypt.digest(password: "admin")
        let user = User(name: "Admin", email: "admin@admin.com", password: hashedPassword, admin: true)
        try database.seed([user])
    }
    
    static func revert(_ database: Database) throws {
    }
}

extension User: Auth.User {
    
    convenience init(credentials: UserCredentials) throws {
        self.init(name: credentials.name, email: credentials.email, password: try BCrypt.digest(password: credentials.password))
    }
    
    static func register(credentials: Credentials) throws -> Auth.User {
        guard let emailPassword = credentials as? UserCredentials else {
            throw Abort.custom(status: .forbidden, message: "Unsupported credentials type \(type(of: credentials))")
        }
        
        let usersForEmail = try User.query().filter("email", emailPassword.email).all()
        if usersForEmail.count != 0 {
            throw RegistrationError.emailTaken
        }
        
        let user = try User(credentials: emailPassword)
        return user
    }
    
    static func authenticate(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let emailPassword as UserLoginCredentials:
            guard let user = try User.query().filter("email", emailPassword.email).first() else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "Invalid email or password")
            }
            
            if try BCrypt.verify(password: emailPassword.password, matchesHash: user.password) {
                return user
            } else {
                throw Abort.custom(status: .networkAuthenticationRequired, message: "Invalid email or password")
            }
        case let id as Identifier:
            guard let user = try User.find(id.id) else {
                throw Abort.custom(status: .forbidden, message: "Invalid user identifier")
            }
            
            return user
        case let api as AccessToken:
            guard let token = try Token.query().filter("token", api.string).first() else {
                throw Abort.custom(status: .forbidden, message: "Invalid token")
            }
            
            guard let user = try User.find(token.user_id) else {
                throw Abort.custom(status: .forbidden, message: "Invalid user identifier")
            }
            
            return user
        default:
            throw Abort.custom(status: .forbidden, message: "Unsupported credentials type \(type(of: credentials))")
        }
    }
}

extension User {
    func tokens() throws -> [Token] {
        return try children("user_id", Token.self).all()
    }
}

struct UserCredentials: Credentials {
    var email: String
    var name: String
    var password: String
    
    init(email: String, name: String, password: String) {
        self.email = email
        self.name = name
        self.password = password
    }
    
    init(json: JSON) throws {
        guard let email = json["email"]?.string else { throw Abort.custom(status: .badRequest, message: "Email must be included") }
        guard let name = json["name"]?.string else { throw Abort.custom(status: .badRequest, message: "Name must be included") }
        guard let password = json["password"]?.string else { throw Abort.custom(status: .badRequest, message: "Password must be included") }
        self.init(email: email, name: name, password: password)
    }
}

struct UserLoginCredentials: Credentials {
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    init(json: JSON) throws {
        guard let email = json["email"]?.string else { throw Abort.custom(status: .badRequest, message: "Email must be included") }
        guard let password = json["password"]?.string else { throw Abort.custom(status: .badRequest, message: "Password must be included") }
        self.init(email: email, password: password)
    }
}

extension Request {
    func user() throws -> User {
        //check to see if it's coming in via an API route
        if uri.description.contains("api/v") {
            guard let APIKey = auth.header?.bearer else { throw Abort.custom(status: .forbidden, message: "Not authorized.") }
            guard let user = try User.authenticate(credentials: APIKey) as? User else { throw Abort.custom(status: .unauthorized, message: "Incorrect key information") }
            return user
        } else {
            guard let user = try auth.user() as? User else { throw Abort.custom(status: .badRequest, message: "Invalid user type.") }
            return user
        }
    }
}

struct UserContext: Context {
    var token: String
}

struct SessionContext: Context { }

enum RegistrationError: Error {
    case emailTaken
}
