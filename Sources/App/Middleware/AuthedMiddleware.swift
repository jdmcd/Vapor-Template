import Vapor
import HTTP

final public class AuthedMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            _ = try request.user()
        } catch {
            return Response(redirect: "/login").flash(.error, "Please login")
        }
        return try next.respond(to: request)
    }
}
