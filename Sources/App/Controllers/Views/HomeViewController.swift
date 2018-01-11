import Vapor
import Leaf
import Authentication

final class HomeViewController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/home", use: home)
    }
    
    //MARK: - GET /home
    func home(_ req: Request) throws -> Future<View> {
        let context = HomeViewContext(userName: "name")
        return try req.view().render("home", context, request: req)
    }
}
