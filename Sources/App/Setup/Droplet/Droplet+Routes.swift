import Vapor

extension Droplet {
    public func routes() throws {
        try collection(RegisterController.self)
        try collection(LoginController.self)
        try collection(MeController.self)
    }
}
