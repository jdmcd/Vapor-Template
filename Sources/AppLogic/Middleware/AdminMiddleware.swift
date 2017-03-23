import Vapor
import HTTP

final public class AdminMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let user = try request.user()
        if user.admin {
            return try next.respond(to: request)
        } else {
            return Response(redirect: "/").flash(.error, "Must be an admin to access that page")
        }
    }
}
