import Vapor
import Leaf

extension TemplateRenderer {
    func render<V>(_ path: String, _ context: V, request: Request) throws -> Future<View> where V: ViewContext {
        let cvc = try request.make(CommonViewContext.self)
        cvc.extend = request.extend
        
        let session = try? request.session()
        cvc.session = session?.data.storage as? [String: String]
        
        var viewContext = context
        viewContext.common = cvc
        
        return render(path, viewContext)
    }
    
    func render(_ path: String, request: Request) throws -> Future<View> {
        var viewContext = SingularCommonViewContext()
        
        let cvc = try request.make(CommonViewContext.self)
        cvc.extend = request.extend
        
        let session = try? request.session()
        cvc.session = session?.data.storage as? [String: String]
        
        viewContext.common = cvc
        
        return render(path, viewContext)
    }
}

struct SingularCommonViewContext: ViewContext {
    var common: CommonViewContext?
}
