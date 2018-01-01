import Vapor
import HTTP
import Authentication

final public class RedirectMiddleware: Middleware {
    
    private var path: String = "/home"
    
    init(path: String) {
        self.path = path
    }
    
    init() { }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        if !(try request.isAuthenticated(User.self)) {
            return Future(request.redirect(to: path))
        }
        
        return try next.respond(to: request)
    }
}
