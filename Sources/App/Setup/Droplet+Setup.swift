import Vapor
import HTTP
import VaporMySQL
import Fluent
import TurnstileCrypto

public func load(_ drop: Droplet) throws {
    drop.preparations.append(User.self)
    drop.preparations.append(Session.self)
    try drop.addProvider(VaporMySQL.Provider)
    
    try loadViews(drop)
    try loadRoutes(drop)
}

//Function to setup routes
fileprivate func loadRoutes(_ drop: Droplet) throws {
    //add routes here
}
