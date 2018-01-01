import Vapor

public final class CommonViewContextProvider: Provider {
    public static let repositoryName = "common-view-context"
    
    public init() {}
    
    public func register(_ services: inout Services) throws {
        services.register(CommonViewContext.self) { container -> CommonViewContext in
            return CommonViewContext(googleAnalyticsKey: "test")
        }
    }
    
    public func boot(_ container: Container) throws { }
}
