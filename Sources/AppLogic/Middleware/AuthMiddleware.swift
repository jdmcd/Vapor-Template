import Vapor
import HTTP

final public class AuthMiddleWare: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let _ = try request.user() {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "login")
        }
    }
}

extension Request {
    func user() throws -> User? {
        guard let userId = try self.session().data["userId"]?.int else { return nil }
        return try User.find(userId)
    }
    
    func APIUser() throws -> User {
        guard let sessionToken = headers["sessionToken"]?.string else { throw Abort.custom(status: .unauthorized, message: "No Session Token Included") }
        guard let sessionSecret = headers["sessionSecret"]?.string else { throw Abort.custom(status: .unauthorized, message: "No Session Secret Included") }
        guard let token = try self.session().data["sessionToken"]?.string else { throw Abort.badRequest }
        guard let secret = try self.session().data["sessionSecret"]?.string else { throw Abort.badRequest }
        
        if sessionToken != token || sessionSecret != secret {
            throw Abort.custom(status: .unauthorized, message: "Incorrect token or key")
        }
        
        guard let user = try user() else { throw Abort.custom(status: .badRequest, message: "User does not exist") }
        return user
    }
}
