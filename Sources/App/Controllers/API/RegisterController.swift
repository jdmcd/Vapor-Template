import Vapor
import Fluent
import Foundation

final class RegisterController: RouteCollection {
    
    func boot(router: Router) throws {
        router.versioned().post("register", use: register)
    }
    
    func register(_ req: Request) throws -> Future<User> {
        let registerRequest = try req.content.decode(RegisterRequest.self)
        let hasher = try req.make(BCryptHasher.self)
        
        let hashedPassword = try hasher.make(registerRequest.password)
        
        let userQuery = User.query(on: req).filter(\.email == registerRequest.email).count()
        return userQuery.flatMap(to: User.self) { count in
            guard count == 0 else { throw Abort(.badRequest, reason: "Email already taken")}
            
            registerRequest.password = hashedPassword
            let newUser = User(registerRequest: registerRequest)
            
            return newUser.save(on: req).map(to: User.self) { _ in
                let _ = try Token(token: UUID().uuidString, user_id: newUser.requireID()).save(on: req)
                return newUser
            }
        }
    }
}
