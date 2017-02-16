import Vapor
import AppLogic

let drop = Droplet()
try load(drop)
drop.run()
