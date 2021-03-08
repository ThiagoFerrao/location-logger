import XCTest
@testable import LocationLogger

final class EndToEndTests: XCTestCase {

    private let locationLogger = LocationLogger.shared

    func test_logMethod() {
        var testResult: LocationLogger.RequestResult?

        let expectation = self.expectation(description: "Callback Executed")
        locationLogger.log(
            requestDomain: "https://httpbin.org/post",
            extraText: "Testing LocationLogger Framework",
            callback: { result in
                testResult = result
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 11, handler: nil)

        XCTAssertNotNil(try testResult?.get())
    }
}
