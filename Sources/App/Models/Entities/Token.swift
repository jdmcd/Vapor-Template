import Foundation
import Vapor
import Fluent
import FluentMySQL

final class Token: Codable, Content {
    var id: Int?
    let token: String
    var user_id: User.ID
    
    var user: Parent<Token, User> {
        return parent(\.user_id)
    }
    
    init(token: String, user_id: User.ID) {
        self.token = token
        self.user_id = user_id
    }
}

extension Token: Model {
    static var idKey: ReferenceWritableKeyPath<Token, Int?> {
        return \.id
    }
    
    typealias Database = MySQLDatabase
    typealias ID = Int
}

extension Token: Migration { }
