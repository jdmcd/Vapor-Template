#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    testCase(LoginTests.allTests),
    testCase(RegistrationTests.allTests),
    testCase(MeTests.allTests),
    testCase(SeedTests.allTests)
])

#endif
