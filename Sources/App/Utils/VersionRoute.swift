import Routing
import Flash
import AuthProvider

struct VersionRoute {
    static let path = "api/v1"
}

extension RouteBuilder {
    func version(handler: (RouteBuilder) -> ()) {
        group(path: [VersionRoute.path], handler: handler)
    }
    
    func versioned() -> RouteBuilder {
        return grouped(VersionRoute.path)
    }
}

extension RouteBuilder {
    fileprivate func middleware(_ type: FrontendMiddlewareType) -> [Middleware] {
        var middleware: [Middleware] = [
            FlashMiddleware(),
            PersistMiddleware(User.self)
        ]
        
        if type == .all {
            middleware.append(AuthedMiddleware())
        }
        
        return middleware
    }
    
    func frontend(_ type: FrontendMiddlewareType = .all, handler: (RouteBuilder) -> ()) {
        group(middleware: middleware(type), handler: handler)
    }
    
    func frontend(_ type: FrontendMiddlewareType = .all) -> RouteBuilder {
        return grouped(middleware(type))
    }
}

enum FrontendMiddlewareType {
    case all
    case noAuthed
}
