import Vapor
import FluentProvider

final class Token: Model {
    var storage = Storage()
    
    let token: String
    let user_id: Identifier
    
    var user: Parent<Token, User> {
        return parent(id: user_id)
    }
    
    init(token: String, user_id: Identifier) {
        self.token = token
        self.user_id = user_id
    }
    
    init(row: Row) throws {
        token = try row.get("token")
        user_id = try row.get("user_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user_id", user_id)
        return row
    }
}

//MARK: - Preparation
extension Token: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { builder in
            builder.id()
            builder.string("token")
            builder.parent(User.self)
        })
    }
    
    static func revert(_ database: Database) throws {
        
    }
}
