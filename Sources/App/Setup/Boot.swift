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
    
    // Register Routes Here
}
