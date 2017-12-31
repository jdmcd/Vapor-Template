import Foundation
import Vapor
import Fluent
import FluentMySQL

final class User: Codable, Content {
    var id: Int?
    var name: String
    var email: String
    var password: String
    var admin: Bool
    
    var token: Children<User, Token> {
        return children(\.user_id)
    }
    
    init(name: String, email: String, password: String, admin: Bool = false) throws {
        self.name = name
        self.email = email
        self.password = password
        self.admin = admin
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
