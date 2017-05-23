import Vapor
import Foundation
import BCrypt
import AuthProvider
import MySQL

final class MeController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.versioned().group(TokenAuthenticationMiddleware(User.self)) { build in
            build.get("me", handler: me)
        }
    }
    
    //GET: - /api/v1/me
    func me(_ req: Request) throws -> ResponseRepresentable {
        return try req.user().makeJSON()
    }
}

//MARK: - EmptyInitializable
extension MeController: EmptyInitializable { }
