import Vapor
import HTTP

final public class AuthedMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        //TODO: - Update this
        return try next.respond(to: request)
    }
}
