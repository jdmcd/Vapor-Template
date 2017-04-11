import Vapor

func registerPreparations(_ drop: Droplet) {
    drop.preparations.append(User.self)
    drop.preparations.append(Token.self)
}
