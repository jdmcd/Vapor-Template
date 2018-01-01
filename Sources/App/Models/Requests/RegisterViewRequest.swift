//
//  RegisterViewRequest.swift
//  App
//
//  Created by Jimmy McDermott on 1/1/18.
//

import Foundation
import Vapor

class RegisterViewRequest: Codable {
    var name: String
    var email: String
    var password: String
    var confirmPassword: String
}
