import XCTest
import Foundation
import Testing
import HTTP
import Fluent
import BCrypt
@testable import Vapor
@testable import App

class SeedTests: TestCase {
    let drop = try! Droplet.testable()
    
    static let userName = "name"
    static let userEmail = "email@email.com"
    static let userPassword = "password"

    static let userTwoName = "name2"
    static let userTwoEmail = "email2@email.com"
    static let userTwoPassword = "password2"
    
    override func setUp() {
        super.setUp()
        
        try! Token.makeQuery().delete()
        try! User.makeQuery().delete()
        
    }
    
    func testSeedData() throws {
        XCTAssertEqual(try User.count(), 0)
        
        try SeedOneData.prepare(try drop.assertDatabase())
        XCTAssertEqual(try User.count(), 1)
        
        guard let user = try User.makeQuery().filter(User.Field.name, SeedTests.userName).first() else {
            XCTFail("User does not exist")
            return
        }
        
        XCTAssertEqual(user.name, SeedTests.userName)
        XCTAssertEqual(user.email, SeedTests.userEmail)
        XCTAssertNotEqual(user.password, SeedTests.userPassword)
    }
    
    func testSeedMultipleData() throws {
        XCTAssertEqual(try User.count(), 0)
        
        try SeedMultipleData.prepare(try drop.assertDatabase())
        XCTAssertEqual(try User.count(), 2)
        
        guard let userOne = try User.makeQuery().filter(User.Field.name, SeedTests.userName).first() else {
            XCTFail("User does not exist")
            return
        }
        
        guard let userTwo = try User.makeQuery().filter(User.Field.name, SeedTests.userTwoName).first() else {
            XCTFail("User does not exist")
            return
        }
        
        XCTAssertEqual(userOne.name, SeedTests.userName)
        XCTAssertEqual(userOne.email, SeedTests.userEmail)
        XCTAssertNotEqual(userOne.password, SeedTests.userPassword)
        
        XCTAssertEqual(userTwo.name, SeedTests.userTwoName)
        XCTAssertEqual(userTwo.email, SeedTests.userTwoEmail)
        XCTAssertNotEqual(userTwo.password, SeedTests.userTwoPassword)
    }
}

//MARK: - SeedOneData
struct SeedOneData: Preparation {
    static func prepare(_ database: Database) throws {
        let hashedPassword = try BCryptHasher().make(SeedTests.userPassword.makeBytes()).makeString()
        try database.seed(User(name: SeedTests.userName, email: SeedTests.userEmail, password: hashedPassword))
    }
    
    static func revert(_ database: Database) throws {
    }
}

//MARK: - SeedMultipleData
struct SeedMultipleData: Preparation {
    static func prepare(_ database: Database) throws {
        let userOneHashedPassword = try BCryptHasher().make(SeedTests.userPassword.makeBytes()).makeString()
        let userTwoHashedPassword = try BCryptHasher().make(SeedTests.userTwoPassword.makeBytes()).makeString()
        
        let userOne = try User(name: SeedTests.userName, email: SeedTests.userEmail, password: userOneHashedPassword)
        let userTwo = try User(name: SeedTests.userTwoName, email: SeedTests.userTwoEmail, password: userTwoHashedPassword)
        
        try database.seed(
            [
                userOne,
                userTwo
            ]
        )
    }
    
    static func revert(_ database: Database) throws {
    }
}


// MARK: Manifest
extension SeedTests {
    static let allTests = [
        ("testSeedData", testSeedData),
        ("testSeedMultipleData", testSeedMultipleData)
    ]
}
