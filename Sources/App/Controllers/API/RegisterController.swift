import Vapor
import Foundation
import BCrypt
import AuthProvider
import MySQL
import Validation

final class RegisterController: RouteCollection {
    func build(_ builder: RouteBuilder) throws {
        builder.version() { build in
            build.post("register", handler: register)
        }
    }
    
    //POST: - /api/v1/register
    func register(_ req: Request) throws -> ResponseRepresentable {
        
        //don't let users who are already authenticated register again
        if let _ = req.auth.header?.bearer {
            throw Abort.badRequest
        }
        
        guard var json = req.json else { throw Abort.badRequest }
        guard let password = json["password"]?.string else { throw Abort.badRequest }
        try json.set("password", try BCryptHasher().make(password.bytes).makeString())
        
        var newUser: User!
        
        do {
            newUser = try User(json: json)
            try newUser.save()
        } catch is MySQLError {
            throw Abort(.badRequest, reason: "Email is already taken")
        } catch is ValidationError {
            throw Abort(.badRequest, reason: "Invalid email")
        }
        
        let newToken = Token(token: UUID().uuidString, user_id: newUser.id!)
        try newToken.save()
        
        let userJSON = try newUser.makeJSON()
        
        return userJSON
    }
}

//MARK: - EmptyInitializable
extension RegisterController: EmptyInitializable { }
