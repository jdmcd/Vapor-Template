@_exported import Vapor
import URI
import RedisProvider
import LeafProvider

extension Droplet {
    public func setup() throws {
        if let viewRenderer = view as? LeafRenderer {
            viewRenderer.stem.register(IfValueIsLessThan())
            viewRenderer.stem.register(IfValueIsGreaterThan())
        }
        
        //Register routes and views
        try routes()
        try views()
    }
}
