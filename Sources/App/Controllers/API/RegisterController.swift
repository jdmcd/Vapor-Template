import Vapor
import Fluent
import Foundation

final class RegisterController: RouteCollection {
    
    func boot(router: Router) throws {
        router.post("/api/v1/register", use: register)
    }
    
    func register(_ req: Request) throws -> Future<User> {
        let registerRequest = try req.content.decode(RegisterRequest.self)
        let hasher = try req.make(BCryptHasher.self)
        
        let hashedPassword = try hasher.make(registerRequest.password)
        
        let userQuery = try User.query(on: req).filter(\.email == registerRequest.email).count()
        return userQuery.flatMap(to: User.self) { count in
            guard count == 0 else { throw Abort(.badRequest, reason: "Email already taken")}
            
            let newUser = User(name: registerRequest.name, email: registerRequest.email, password: hashedPassword)
            
            return newUser.save(on: req).map(to: User.self) { _ in
                let _ = try Token(token: UUID().uuidString, user_id: newUser.requireID()).save(on: req)
                return newUser
            }
        }
    }
}


