import Vapor

extension Config {
    func setupPreparations() {
        preparations.append(User.self)
        preparations.append(Token.self)
    }
}
