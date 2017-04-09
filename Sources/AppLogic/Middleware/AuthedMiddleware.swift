import Vapor
import HTTP

final public class AuthedMiddleware: Middleware {
    var isAPI: Bool = false
    
    init(isAPI: Bool = false) {
        self.isAPI = isAPI
    }
    
    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            _ = try request.user()
        } catch {
            if isAPI {
                throw Abort.custom(status: .forbidden, message: "Not authorized.")
            }
            return Response(redirect: "login").flash(.error, "Please login")
        }
        return try next.respond(to: request)
    }
}
