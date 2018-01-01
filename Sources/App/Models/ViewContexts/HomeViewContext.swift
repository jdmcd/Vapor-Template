import Foundation

struct HomeViewContext: ViewContext {
    var common: CommonViewContext?
    var userName: String
    
    init(userName: String) {
        self.userName = userName
    }
}
