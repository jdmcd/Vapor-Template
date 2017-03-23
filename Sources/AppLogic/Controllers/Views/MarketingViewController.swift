import Vapor
import HTTP
import Auth
import Turnstile

final class MarketingViewController {
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.get("/", handler: landingView)
    }
    
    func landingView(_ req: Request) throws -> ResponseRepresentable {
        return ""
    }
}
