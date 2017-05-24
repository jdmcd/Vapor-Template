import Vapor
import Fluent

extension Database {
    func seed<T: Entity>(_ objects: [T]) throws {
        let query = try T.makeQuery(self)
        
        try objects.forEach {
            try query.save($0)
        }
    }
    
    func seed<T: Entity>(_ object: T) throws {
        try seed([object])
    }
}
