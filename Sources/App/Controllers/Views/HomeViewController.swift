import Vapor

final class HomeViewController: RouteCollection {
    func boot(router: Router) throws {
        router.get("/home", use: home)
    }
    
    //MARK: - GET /home
    func home(_ req: Request) throws -> Future<String> {
        return Future("")
    }
}

