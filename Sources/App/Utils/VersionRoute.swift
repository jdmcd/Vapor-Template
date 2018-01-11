import Vapor
import Fluent
import Authentication

struct VersionRoute {
    static let path = PathComponent(stringLiteral: "api/v1")
}

extension Router {
    func versioned(handler: @escaping (RouteGroup) -> ()) {
        group(VersionRoute.path, use: handler)
    }
    
    func versioned() -> RouteGroup {
        return grouped(VersionRoute.path)
    }
    
    func tokenAuthed(handler: @escaping (RouteGroup) -> ()) throws {
        group(try User.tokenAuthMiddleware(), use: handler)
    }
    
    func tokenAuthed() throws -> RouteGroup {
        return grouped(try User.tokenAuthMiddleware())
    }
}


//import Routing
//import AuthProvider
//
//struct VersionRoute {
//    static let path = "api/v1"
//}
//
//extension RouteBuilder {

//}
//
//extension RouteBuilder {
//    fileprivate func middleware(_ type: FrontendMiddlewareType) -> [Middleware] {
//        var middleware: [Middleware] = [
//            FlashMiddleware(),
//            PersistMiddleware(User.self)
//        ]
//
//        if type == .all {
//            middleware.append(AuthedMiddleware())
//        }
//
//        return middleware
//    }
//
//    func frontend(_ type: FrontendMiddlewareType = .all, handler: (RouteBuilder) -> ()) {
//        group(middleware: middleware(type), handler: handler)
//    }
//
//    func frontend(_ type: FrontendMiddlewareType = .all) -> RouteBuilder {
//        return grouped(middleware(type))
//    }
//}
//
//enum FrontendMiddlewareType {
//    case all
//    case noAuthed
//} 
