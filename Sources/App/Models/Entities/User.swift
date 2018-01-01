import Foundation
import Vapor
import Fluent
import FluentMySQL

final class User: Codable, Content {
    var id: Int?
    var name: String
    var email: String
    var password: String
    
    var token: Children<User, Token> {
        return children(\.user_id)
    }
    
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
}

extension User: Model {
    static var idKey: ReferenceWritableKeyPath<User, Int?> {
        return \.id
    }
    
    typealias Database = MySQLDatabase
    typealias ID = Int
}

extension User: Migration { }

//MARK: - LoginResponse
extension User {
    func publicUser(token: String) throws -> PublicUser {
        return try PublicUser(user: self, token: token)
    }
    
    struct PublicUser: Codable, Content {
        var id: Int
        var name: String
        var email: String
        var token: String
        
        init(user: User, token: String) throws {
            id = try user.requireID()
            name = user.name
            email = user.email
            self.token = token
        }
    }
}

//TODO: - token stuff
//MARK: - SessionPersistable
//extension User: SessionPersistable { }
//
////MARK: - Timestampable
//extension User: Timestampable { }
//
////MARK: - UserContext
//struct UserContext: Context {
//    var token: String
//}
//
////MARK: - Authenticate/UnAuthenticate
//extension User {
//    func authenticate(req: Request) throws {
//        try req.auth.authenticate(self, persist: true)
//        try setSession(req: req)
//    }
//
//    private func setSession(req: Request) throws {
//        try req.assertSession().data["user"] = self.makeJSON().makeNode(in: nil)
//    }
//
//    func unauthenticate(req: Request) throws {
//        try req.auth.unauthenticate()
//        try req.assertSession().destroy()
//    }
//}
//
