import Vapor
import Fluent
import Foundation

final class LoginController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post("/login", use: login)
    }
    
    func login(_ req: Request) throws -> Future<User.PublicUser> {
        let invalidCredentials = Abort(.badRequest, reason: "Invalid credentials")
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        let query = try User.query(on: req).filter(joined: \User.email == loginRequest.email).first()
        
        return query.flatMap(to: User.PublicUser.self) { user in
            guard let user = user else { throw invalidCredentials }
            let hasher = try req.make(BCryptHasher.self)
            
            if try hasher.verify(message: loginRequest.password, matches: user.password) {
                return try user.token.query(on: req).first().map(to: User.PublicUser.self) { token in
                    if let token = token {
                        return try user.publicUser(token: token.token)
                    } else {
                        let uuid = UUID().uuidString
                        let _ = try Token(token: uuid, user_id: user.requireID()).save(on: req)
                        
                        return try user.publicUser(token: uuid)
                    }
                }

            } else {
                throw invalidCredentials
            }
        }
    }
}
