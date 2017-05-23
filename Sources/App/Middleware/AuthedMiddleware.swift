import Vapor
import HTTP

final public class AuthedMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            _ = try request.user()
            return try next.respond(to: request)
        } catch {
            return Response(redirect: "/login").flash(.error, "Please login")
        }
    }
}
