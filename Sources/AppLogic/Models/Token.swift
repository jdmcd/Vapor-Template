import Foundation
import Vapor
import Fluent
import TurnstileCrypto

final class Token: Model {
    var id: Node?
    var user_id: Int
    var token: String
    
    var exists: Bool = false
    
    init(user_id: Int) {
        self.user_id = user_id
        self.token = TurnstileCrypto.URandom().secureToken
    }
    
    init(node: Node, in context: Context) throws {
        self.id = nil
        self.user_id = try node.extract("user_id")
        self.token = try node.extract("token")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": user_id,
            "token": token
        ])
    }
}

//MARK: - Preparation
extension Token: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("tokens", closure: { token in
            token.id()
            token.string("token")
            token.parent(User.self)
        })
    }
    
    static func revert(_ database: Database) throws {
    }
}
