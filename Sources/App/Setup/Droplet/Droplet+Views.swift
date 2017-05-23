import Vapor

extension Droplet {
    public func views() throws {
        try collection(LoginViewController(view))
        try collection(RegisterViewController(view))
    }
}
