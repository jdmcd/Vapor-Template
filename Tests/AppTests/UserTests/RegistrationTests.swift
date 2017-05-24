import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import App

class RegistrationTests: TestCase {
    let drop = try! Droplet.testable()
    
    static let token = ""
    
    override func setUp() {
        super.setUp()
        
        try! Token.makeQuery().delete()
        try! User.makeQuery().delete()
    }
    
    func testRegister() throws {
        var json = JSON()
        
        try json.set("name", "name")
        try json.set("email", "email@email.com")
        try json.set("password", "password")
        
        let body = try Body(json)
        try createUserWithSuccess(body: body)
    }
    
    func testFailedRegister() throws {
        var json = JSON()
        try json.set("name", "name")
        
        let body = try Body(json)
        try failAgainstData(body: body)
        
        try json.set("email", "email@email.com")
        try failAgainstData(body: body)
    }
    
    func testDuplicateEmail() throws {
        var json = JSON()
        
        try json.set("name", "name")
        try json.set("email", "email@email.com")
        try json.set("password", "password")
        
        let body = try Body(json)
        
        //create the user
        try createUserWithSuccess(body: body)
        
        //fail because the email is a duplicate
        try failAgainstData(body: body)
    }
    
    func testInvalidEmail() throws {
        var json = JSON()
        
        try json.set("name", "name")
        try json.set("email", "INVALIDEMAIL")
        try json.set("password", "password")
        
        let body = try Body(json)
        
        try failAgainstData(body: body)
    }
    
    //MARK: - failAgainstData
    private func failAgainstData(body: Body) throws {
        let request = Request(method: .post,
                              uri: "/api/v1/register",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        try drop.testResponse(to: request)
            .assertStatus(is: .badRequest)
            .assertJSON("id", passes: { json in json.int == nil })
            .assertJSON("token", passes: { json in json.string == nil })
    }
    
    //MARK: - createUserWithSuccess
    private func createUserWithSuccess(body: Body) throws {
        let request = Request(method: .post,
                              uri: "/api/v1/register",
                              headers: ["Content-Type": "application/json"],
                              body: body)
        
        try drop.testResponse(to: request)
            .assertStatus(is: .ok)
            .assertJSON("id", passes: { json in json.int != nil })
            .assertJSON("token", passes: { json in json.string != nil })
            .assertJSON("name", equals: "name")
            .assertJSON("email", equals: "email@email.com")
            .assertJSON("password", passes: { json in json.string == nil })
    }
}

// MARK: Manifest
extension RegistrationTests {
    static let allTests = [
        ("testRegister", testRegister),
        ("testFailedRegister", testFailedRegister),
        ("testDuplicateEmail", testDuplicateEmail),
        ("testInvalidEmail", testInvalidEmail)
    ]
}
