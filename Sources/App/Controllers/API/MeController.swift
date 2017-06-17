import Vapor
import Foundation
import BCrypt
import AuthProvider
import MySQL

final class MeController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.versioned().group(TokenAuthenticationMiddleware(User.self)) { build in
            build.get("me", handler: me)
            build.patch("me", handler: updateMe)
            build.patch("password", handler: updatePassword)
        }
    }
    
    //MARK: - GET /api/v1/me
    func me(_ req: Request) throws -> ResponseRepresentable {
        return try req.user().makeJSON()
    }
    
    //MARK: - PATCH /api/v1/me
    func updateMe(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else { throw Abort.badRequest }
        
        let currentUser = try req.user()
        currentUser.name = try json.get("name") ?? currentUser.name
        currentUser.email = try json.get("email") ?? currentUser.email
        
        do {
            try currentUser.save()
        } catch is MySQLError {
            throw Abort(.badRequest, reason: "The email or screen name you have entered is taken")
        } catch {
            throw Abort(.badRequest, reason: "Something went wrong. Please try again")
        }
        
        return try currentUser.makeJSON()
    }
    
    //MARK: - PATCH /api/v1/password
    func updatePassword(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else { throw Abort(.badRequest, reason: "Invalid JSON") }
        
        let oldPassword: String = try json.get("oldPassword")
        let newPassword: String = try json.get("newPassword")
        let user = try req.user()
        
        if !(try BCryptHasher().verify(password: oldPassword.bytes, matches: user.password.bytes)) {
            throw Abort(.unauthorized, reason: "Incorrect old password")
        }
        
        user.password = try BCryptHasher().make(newPassword.bytes).makeString()
        try user.save()
        
        return try user.makeJSON()
    }
}

//MARK: - EmptyInitializable
extension MeController: EmptyInitializable { }
