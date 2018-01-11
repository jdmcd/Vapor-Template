import Foundation
import Vapor
import Fluent
import FluentMySQL
import Authentication

final class Token: Codable, Content {
    var id: Int?
    var token: String
    var user_id: User.ID
    
    var user: Parent<Token, User> {
        return parent(\.user_id)
    }
    
    init(token: String, user_id: User.ID) {
        self.token = token
        self.user_id = user_id
    }
}

extension Token: MySQLModel {
    static var idKey: ReferenceWritableKeyPath<Token, Int?> {
        return \.id
    }
}

extension Token: Migration { }

extension Token: BearerAuthenticatable, Authentication.Token {
    static var userIDKey: ReferenceWritableKeyPath<Token, Int> {
        return \.user_id
    }
    
    typealias UserType = User
    
    static var tokenKey: ReferenceWritableKeyPath<Token, String> {
        return \.token
    }
}
