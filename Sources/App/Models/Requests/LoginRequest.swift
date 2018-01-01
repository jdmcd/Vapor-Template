//
//  LoginRequest.swift
//  App
//
//  Created by Jimmy McDermott on 12/31/17.
//

import Foundation
import Vapor

struct LoginRequest: Codable {
    var email: String
    var password: String
}
