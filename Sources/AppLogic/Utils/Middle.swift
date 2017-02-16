import Vapor
import HTTP

//make sure that protected pages have the right access levels
final public class AuthMiddleWare: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let sessionToken = try request.session().data["sessionToken"]?.string else {
            return Response(redirect: "login")
        }
        
        guard let sessionSecret = try request.session().data["sessionSecret"]?.string else {
            return Response(redirect: "login")
        }
        
        let sessions = try Session.query().filter("token", sessionToken).all()
        if sessions.isEmpty {
            return Response(redirect: "login")
        }
        
        let firstSession = sessions.first!
        if firstSession.secret == sessionSecret {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "login")
        }
    }
}

final public class APIProtection: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let _ = try request.APIUser()
        return try next.respond(to: request)
    }
}

//redirect to home if they're already logged in
final public class RedirectMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if try request.user() != nil {
            return Response(redirect: "home")
        } else {
            return try next.respond(to: request)
        }
    }
}

//helper method for getting the `User` from a request
extension Request {
    func user() throws -> User? {
        guard let sessionToken = try self.session().data["sessionToken"]?.string else {
            return nil
        }
        
        guard let sessionSecret = try self.session().data["sessionSecret"]?.string else {
            return nil
        }
        
        let sessions = try Session.query().filter("token", sessionToken).all()
        if sessions.isEmpty {
            return nil
        }
        
        let firstSession = sessions.first!
        if firstSession.secret == sessionSecret {
            if let user = try User.find(firstSession.user) {
                return user
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func APIUser() throws -> User {
        guard let sessionToken = headers["sessionToken"]?.string else { throw Abort.custom(status: .unauthorized, message: "No Session Token Included") }
        guard let sessionSecret = headers["sessionSecret"]?.string else { throw Abort.custom(status: .unauthorized, message: "No Session Secret Included") }
        guard let session = try Session.query().filter("token", sessionToken).filter("secret", sessionSecret).all().first else { throw Abort.custom(status: .unauthorized, message: "Invalid Token/Key") }
        guard let user = try User.find(session.user) else { throw Abort.custom(status: .unauthorized, message: "User Does Not Exist") }
        return user
    }
}
