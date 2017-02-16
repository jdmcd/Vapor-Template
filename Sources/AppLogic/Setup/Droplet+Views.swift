import Vapor
import HTTP

//Function to setup views
public func loadViews(_ drop: Droplet) throws {
    drop.get { req in
        return ""
    }
}
