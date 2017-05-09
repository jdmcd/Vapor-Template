import XCTest
import Vapor
import HTTP
import TurnstileCrypto
import Foundation
@testable import AppLogic

class UserTests: XCTestCase {
    
    static let allTests = [
        ("createUserNative", createUserNative)
    ]
    
    static let email = "jimmy@162llc.com"
    static let password = "password"
    static let name = "Jimmy McDermott"
    static var token: String!
    static var secret: String!
    static var userId: Int!
    
    static var drop: Droplet!
    
    override func setUp() {
        do {
            UserTests.drop = try! makeTestDroplet()
            
            try User.query().delete()
            try Session.query().delete()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func createUserNative() throws {
        let hashedPassword = BCrypt.hash(password: UserTests.password)
        var newUser = User(name: UserTests.name, email: UserTests.email, password: hashedPassword, profileUrl: "")
        try newUser.save()
        
        XCTAssertEqual(newUser.name, UserTests.name)
        XCTAssertEqual(newUser.email, UserTests.email)
        
        //check for BCrypt success
        guard let fetchedUser = try User.find(newUser.id!) else { XCTFail("Couldn't find user"); return }
        XCTAssertNotEqual(fetchedUser.password, UserTests.password)
        XCTAssertTrue(try BCrypt.verify(password: UserTests.password, matchesHash: fetchedUser.password))
    }
}
