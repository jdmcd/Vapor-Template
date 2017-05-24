import Vapor
import Fluent

extension Database {
    func seed<T: Entity>(_ objects: [T]) throws {
        try transaction { conn in
            try objects.forEach {
                let query = try T.makeQuery(conn)
                try query.save($0)
            }
        }
    }
    
    func seed<T: Entity>(_ object: T) throws {
        try seed([object])
    }
}
