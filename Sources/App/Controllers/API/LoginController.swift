import Vapor
import Foundation
import BCrypt
import AuthProvider
import MySQL

final class LoginController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.version() { build in
            build.post("login", handler: login)
        }
    }
    
    //MARK: - POST /api/v1/login
    func login(_ req: Request) throws -> ResponseRepresentable {
        let invalidCredentials = Abort(.badRequest, reason: "Invalid credentials")
        
        guard let json = req.json else { throw Abort.badRequest }
        
        //TODO: - When Swift 4 is released add a generic subscript to `StructuredDataWrapper` so that `.rawValue` doesn't have to be used. See: https://github.com/apple/swift-evolution/blob/master/proposals/0148-generic-subscripts.md
        guard let email = json[User.Field.email.rawValue]?.string else { throw Abort.badRequest }
        guard let password = json[User.Field.password.rawValue]?.string else { throw Abort.badRequest }
        
        guard let user = try User.makeQuery().filter(User.Field.email, email).first() else { throw invalidCredentials }
        
        if try BCryptHasher().verify(password: password, matches: user.password) {
            if try user.token() == nil {
                let newToken = Token(token: UUID().uuidString, user_id: user.id!)
                try newToken.save()
            }
            
            return try user.makeJSON()
        } else {
            throw invalidCredentials
        }
    }
}

//MARK: - EmptyInitializable
extension LoginController: EmptyInitializable { }
