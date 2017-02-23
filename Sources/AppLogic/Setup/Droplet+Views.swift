import Vapor
import HTTP

//Function to setup views
public func loadViews(_ drop: Droplet) throws {
    drop.get { req in
        return ""
    }
    
    //redirect these calls back home if the user is already logged in
    drop.group(RedirectMiddleware(path: "home")) { redirect in
        redirect.get("login") { req in
            return try drop.view.make("login", for: req)
        }
        
        redirect.post("login") { req in
            guard let data = req.formURLEncoded else { throw Abort.badRequest }
            return try User.loginFrontend(data: data, req: req)
        }
        
        redirect.get("register") { req in
            return try drop.view.make("register", for: req)
        }
        
        redirect.post("register") { req in
            return try User.registerFromView(req: req)
        }
    }
    
    //protect these routes for logged in users
    drop.group(AuthMiddleWare()) { authed in
        authed.get("logout") { req in
            guard let user = try req.user() else { throw Abort.badRequest }
            return try user.logoutFrontend(req: req)
        }
    }
}
