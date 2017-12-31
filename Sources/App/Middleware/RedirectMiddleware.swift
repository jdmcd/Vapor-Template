import Vapor
import HTTP

final public class RedirectMiddleware: Middleware {
    
    private var path: String = "/home"
    
    init(path: String) {
        self.path = path
    }
    
    init() { }
    
    //TODO: - Update auth here
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        do {
//            _ = try request.user()
            return Future(request.redirect(to: path))
        } catch {
            return try next.respond(to: request)
        }
    }
}
