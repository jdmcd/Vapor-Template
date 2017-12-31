//
//  RegisterRequest.swift
//  App
//
//  Created by Jimmy McDermott on 12/31/17.
//

import Foundation
import Vapor

class RegisterRequest: Codable {
    var name: String
    var email: String
    var password: String
}
