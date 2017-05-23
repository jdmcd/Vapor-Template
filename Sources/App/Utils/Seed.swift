//import Vapor
//import Fluent
//
//extension Database {
//    func seed<T: Entity, S: Sequence>(_ data: S) throws where S.Iterator.Element == T {
//        try data.forEach { model in
//            let query = Query<T>(self)
//            query.action = .create
//            query.data = try model.makeRow()
//            try driver.query(query)
//        }
//    }
//}
