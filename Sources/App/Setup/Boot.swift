//
//  Boot.swift
//  App
//
//  Created by Jimmy McDermott on 12/31/17.
//

import Foundation
import Vapor

public func boot(_ app: Application) throws {
    let router = try app.make(Router.self)
    
    try router.register(collection: LoginController())
    try router.register(collection: RegisterController())
    try router.register(collection: HomeViewController())
    try router.register(collection: LoginViewController())
    try router.register(collection: RegisterViewController())
    try router.register(collection: MeController())
    //TODO: - split this up into views and routes
}
