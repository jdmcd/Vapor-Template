import Vapor

class CommonViewContext: Encodable {
    var extend: Extend?
    var googleAnalyticsKey: String
    var session: [String: String]?
    
    init(googleAnalyticsKey: String) {
        self.googleAnalyticsKey = googleAnalyticsKey
    }
}
