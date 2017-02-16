import Vapor
import Fluent
import Foundation
import TurnstileCrypto
import TurnstileWeb
import Turnstile

final class Session: Model {
    var id: Node?
    var user: Int
    var token: String
    var secret: String
    
    var exists: Bool = false
    
    init(user: Int) {
        self.user = user
        self.token = TurnstileCrypto.URandom().secureToken
        self.secret = TurnstileCrypto.URandom().secureToken
    }
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        user = try node.extract("user_id")
        token = try node.extract("token")
        secret = try node.extract("secret")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": user,
            "token": token,
            "secret": secret
            ])
    }
}

extension Session: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("sessions", closure: { session in
            session.id()
            session.parent(User.self, optional: false)
            session.string("token", length: 255, optional: false)
            session.string("secret", length: 255, optional: false)
        })
    }
    
    static func revert(_ database: Database) throws {
        //
    }
}
