import Routing

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
