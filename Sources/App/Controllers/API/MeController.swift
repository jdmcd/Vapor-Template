import Vapor
import Fluent
import Foundation
import Authentication

final class MeController: RouteCollection {
    
    func boot(router: Router) throws {
        try router.versioned().tokenAuthed().get("me", use: me)
    }
    
    func me(_ req: Request) throws -> Future<User.PublicUser> {
        let user = try req.user()
        
        //get the user's token
        return try user.token.query(on: req).first().map(to: User.PublicUser.self) { token in
            guard let token = token else { throw Abort(.badRequest) }
            return try user.publicUser(token: token.token)
        }
    }
}
