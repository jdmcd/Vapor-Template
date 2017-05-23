import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class MeTests: TestCase {
    let drop = try! Droplet.testable()
    var userJson: JSON!
    
    override func setUp() {
        super.setUp()
        
        try! Token.makeQuery().delete()
        try! User.makeQuery().delete()
        
        userJson = try! createUser()
    }
    
    func testAuthorized() throws {
        guard let token = userJson["token"]?.string else { XCTFail(); return }
        
        let request = Request(method: .get,
                              uri: "/api/v1/me",
                              headers: ["Content-Type": "application/json", "Authorization": "Bearer \(token)"])
        
        try drop.testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("id", passes: { json in json.int != nil })
            .assertJSON("token", passes: { json in json.string != nil })
            .assertJSON("name", passes: { json in json.string == userJson["name"]?.string })
            .assertJSON("email", passes: { json in json.string == userJson["email"]?.string })
            .assertJSON("password", passes: { json in json.string == nil })
    }
    
    func testNotAuthorized() throws {
        let request = Request(method: .get,
                              uri: "/api/v1/me",
                              headers: ["Content-Type": "application/json", "Authorization": "Bearer RANDOMTOKEN"])
        
        try drop.testResponse(to: request)
            .assertStatus(is: .forbidden)
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
extension MeTests {
    static let allTests = [
        ("testAuthorized", testAuthorized),
        ("testNotAuthorized", testNotAuthorized)
    ]
}
