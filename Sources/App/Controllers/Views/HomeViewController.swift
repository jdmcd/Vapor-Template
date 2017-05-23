import Vapor
import Flash

final class HomeViewController: RouteCollection {
    private let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        builder.grouped(FlashMiddleware()).group(AuthedMiddleware()) { build in
            build.get("/home", handler: home)
        }
    }
    
    //MARK: - GET /home
    func home(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
}
