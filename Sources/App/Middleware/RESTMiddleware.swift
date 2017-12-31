import Vapor
import HTTP

final public class RESTMiddleware: Middleware {
    public func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let unauthorizedError = Abort(.unauthorized, reason: "Please include an API-KEY")
        
        let correctAPIKey = "correct key"
        guard let submittedAPIKey = request.headers["API-KEY"] else { throw unauthorizedError }
        
        if correctAPIKey == submittedAPIKey {
            return try next.respond(to: request)
        } else {
            throw unauthorizedError
        }
    }
}
