import Vapor
import HTTP

final public class RedirectMiddleware: Middleware {
    var path: String
    
    init(path: String) {
        self.path = path
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if try request.user() != nil {
            return Response(redirect: path)
        } else {
            return try next.respond(to: request)
        }
    }
}
