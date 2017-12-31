import Vapor
import Fluent
import Foundation

final class LoginController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post("/login", use: login)
    }
    
    func login(_ req: Request) throws -> Future<User> {
        let invalidCredentials = Abort(.badRequest, reason: "Invalid credentials")
        let loginRequest = try req.content.decode(LoginRequest.self)
        
        let query = try User.query(on: req).filter(joined: \User.email == loginRequest.email).first()
        
        return query.flatMap(to: User.self) { user in
            guard let user = user else { throw invalidCredentials }
            let hasher = try req.make(BCryptHasher.self)
            
            if try hasher.verify(message: user.password, matches: loginRequest.password) {
                return try user.token.query(on: req).count().map(to: User.self) { count in
                    if count == 0 {
                        let _ = try Token(token: UUID().uuidString, user_id: user.requireID()).save(on: req)
                    }
                    
                    return user
                }

            } else {
                throw invalidCredentials
            }
        }
    }
}
