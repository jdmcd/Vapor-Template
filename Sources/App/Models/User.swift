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
    
    static func login(req: Request) throws -> Response {
        let form = req.formURLEncoded
        guard let email = form?["email"]?.string else {
            throw Abort.badRequest
        }
        
        guard let submittedPassword = form?["password"]?.string else {
            throw Abort.badRequest
        }
        
        let fetchedUser = try User.query()
            .filter("email", email)
            .first()
        
        if let password = fetchedUser?.password, password != "", (try? BCrypt.verify(password: submittedPassword, matchesHash: password)) == true {
            //they passed verification
            
            var newSession = Session(user: fetchedUser!.id!.int!)
            try newSession.save()
            
            try req.session().data["sessionToken"] = Node.string(newSession.token)
            try req.session().data["sessionSecret"] = Node.string(newSession.secret)
            
            return Response(redirect: "home")
        } else {
            return Response(redirect: "login")
        }
    }
    
    func logout(req: Request) throws -> Response {
        try Session.query().filter("user_id", id!.int!).delete()
        try req.session().destroy()
        return Response(redirect: "/")
    }
}
