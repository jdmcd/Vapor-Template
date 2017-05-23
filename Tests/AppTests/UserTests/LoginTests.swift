import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class LoginTests: TestCase {
    let drop = try! Droplet.testable()
    
    override func setUp() {
        super.setUp()
        
        try! Token.makeQuery().delete()
        try! User.makeQuery().delete()
    }
    
    func testLogin() throws {
        let userJson = try createUser()
        
        var newJson = JSON()
        try newJson.set("email", userJson!["email"]?.string)
        try newJson.set("password", "password")
        
        let body = try Body(newJson)
        
        let request = Request(method: .post,
                              uri: "/api/v1/login",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        try drop.testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("id", passes: { json in json.int != nil })
            .assertJSON("token", passes: { json in json.string != nil })
            .assertJSON("name", passes: { json in json.string == "name" })
            .assertJSON("email", passes: { json in json.string == "email@email.com" })
            .assertJSON("password", passes: { json in json.string == nil })
    }
    
    func testLoginFail() throws {
        try createUser()
        
        var newJson = JSON()
        try newJson.set("email", "WRONG EMAIL")
        try newJson.set("password", "WRONG PASSWORD")
        
        let body = try Body(newJson)
        
        let request = Request(method: .post,
                              uri: "/api/v1/login",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        try drop.testResponse(to: request)
            .assertStatus(is: .badRequest)
            .assertJSON("id", passes: { json in json.int == nil })
            .assertJSON("token", passes: { json in json.string == nil })
    }
    
    //MARK: - createUser
    @discardableResult
    private func createUser() throws -> JSON? {
        var json = JSON()
        
        try json.set("name", "name")
        try json.set("email", "email@email.com")
        try json.set("password", "password")
        
        let body = try Body(json)
        
        let request = Request(method: .post,
                              uri: "/api/v1/register",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        let response = try drop.testResponse(to: request)
        guard let responseJson = response.json else { XCTFail(); return nil }
        return responseJson
    }
}

// MARK: Manifest
extension LoginTests {
    static let allTests = [
        ("testLogin", testLogin),
        ("testLoginFail", testLoginFail)
    ]
}
