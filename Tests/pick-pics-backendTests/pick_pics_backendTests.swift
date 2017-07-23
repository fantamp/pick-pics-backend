import XCTest
@testable import pick_pics_backend

class pick_pics_backendTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(pick_pics_backend().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
