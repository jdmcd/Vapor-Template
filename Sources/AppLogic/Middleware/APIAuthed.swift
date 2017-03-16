import Vapor
import HTTP

final public class APIAuthed: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let _ = try request.APIUser()
        return try next.respond(to: request)
    }
}
