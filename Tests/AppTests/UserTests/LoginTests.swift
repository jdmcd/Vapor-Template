import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App
import BCrypt

class LoginTests: TestCase {
    let drop = try! Droplet.testable()
    
    let registerName = "name"
    let email = "email@email.com"
    let password = "password"
    
    override func setUp() {
        super.setUp()
        
        try! Token.makeQuery().delete()
        try! User.makeQuery().delete()
    }
    
    func testLogin() throws {
        let userJson = try createUser()
        
        var newJson = JSON()
        try newJson.set("email", userJson!["email"]?.string)
        try newJson.set("password", password)
        
        let body = try Body(newJson)
        try loginUser(body: body)
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
    
    func testTokenDoesNotExistOnLogin() throws {
        let newUser = try User(name: registerName, email: email, password: try BCryptHasher().make(password.makeBytes()).makeString())
        try newUser.save()
        
        var json = JSON()
        
        try json.set("email", email)
        try json.set("password", password)
        
        XCTAssert(try Token.makeQuery().filter("user_id", newUser.id!).count() == 0)
        
        try loginUser(body: try Body(json))
        
        XCTAssert(try Token.makeQuery().filter("user_id", newUser.id!).count() != 0)
    }
    
    //MARK: - createUser
    @discardableResult
    private func createUser() throws -> JSON? {
        var json = JSON()
        
        try json.set("name", registerName)
        try json.set("email", email)
        try json.set("password", password)
        
        let body = try Body(json)
        
        let request = Request(method: .post,
                              uri: "/api/v1/register",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        let response = try drop.testResponse(to: request)
        guard let responseJson = response.json else { XCTFail(); return nil }
        return responseJson
    }
    
    //MARK: - checkUser
    func loginUser(body: Body) throws {
        let request = Request(method: .post,
                              uri: "/api/v1/login",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        try drop.testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("id", passes: { json in json.int != nil })
            .assertJSON("token", passes: { json in json.string != nil })
            .assertJSON("name", passes: { json in json.string == registerName })
            .assertJSON("email", passes: { json in json.string == email })
            .assertJSON("password", passes: { json in json.string == nil })
    }
}

// MARK: Manifest
extension LoginTests {
    static let allTests = [
        ("testLogin", testLogin),
        ("testLoginFail", testLoginFail),
        ("testTokenDoesNotExistOnLogin", testTokenDoesNotExistOnLogin)
    ]
}
