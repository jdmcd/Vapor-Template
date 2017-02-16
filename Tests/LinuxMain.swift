#if os(Linux)
    
    import XCTest
    @testable import AppLogicTests
    
XCTMain([
    testCase(UserTests.allTests),
    ])
    
#endif
