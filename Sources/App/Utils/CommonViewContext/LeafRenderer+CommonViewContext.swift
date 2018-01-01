import Vapor
import Leaf

extension LeafRenderer {
    func make<V>(_ path: String, _ context: V, request: Request) throws -> Future<View> where V: ViewContext {
        let cvc = try request.make(CommonViewContext.self)
        cvc.extend = request.extend
        
        let session = try? request.session()
        cvc.session = session?.data as? [String: String]
        
        var viewContext = context
        viewContext.common = cvc
        
        return try make(path, viewContext)
    }
    
    public func make(_ path: String, request: Request) throws -> Future<View> {
        struct SingularCommonViewContext: ViewContext {
            var common: CommonViewContext?
        }
        
        var viewContext = SingularCommonViewContext()
        
        let cvc = try request.make(CommonViewContext.self)
        cvc.extend = request.extend
        
        let session = try? request.session()
        cvc.session = session?.data as? [String: String]
        
        viewContext.common = cvc
        
        return try make(path, viewContext)
    }
}
