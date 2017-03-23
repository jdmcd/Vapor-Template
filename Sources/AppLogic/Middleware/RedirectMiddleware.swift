import Vapor
import HTTP

final public class RedirectMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            _ = try request.user()
            return Response(redirect: "home")
        } catch {
            return try next.respond(to: request)
        }
    }
}
