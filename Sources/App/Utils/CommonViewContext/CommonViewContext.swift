import Vapor

class CommonViewContext: Encodable, Service {
    var extend: Extend?
    var googleAnalyticsKey: String
    var session: [String: String]?
    
    init(googleAnalyticsKey: String) {
        self.googleAnalyticsKey = googleAnalyticsKey
    }
}
