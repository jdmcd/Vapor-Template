import Vapor
import HTTP

class RESTMiddleware: Middleware {
    let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let unauthorizedError = Abort(.unauthorized, reason: "Please include an API-KEY")
        
        guard let correctAPIKey = config["app", "API-KEY"]?.string else { throw Abort.badRequest }
        guard let submittedAPIKey = request.headers["API-KEY"]?.string else { throw unauthorizedError }
        
        if correctAPIKey == submittedAPIKey {
            return try next.respond(to: request)
        } else {
            throw unauthorizedError
        }
    }
}
