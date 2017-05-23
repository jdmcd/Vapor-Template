import Vapor
import HTTP

final public class RedirectMiddleware: Middleware {
    
    private var path: String = "/home"
    
    init(path: String) {
        self.path = path
    }
    
    init() {
        
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            _ = try request.user()
            return Response(redirect: path)
        } catch {
            return try next.respond(to: request)
        }
    }
}
