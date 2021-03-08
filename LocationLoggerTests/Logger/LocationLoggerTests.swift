import XCTest
import CoreLocation
@testable import LocationLogger

final class LocationLoggerTests: XCTestCase {

    typealias TestLogResult = Result<Data?, TestError>
    typealias TestAuthorizationResult = Result<CLAuthorizationStatus, TestError>

    private let testLocationManager = MockLocationManager.shared
    private let testNetwork = MockNetwork.shared
    private var locationLogger: LocationLogger!

    private let testExpectationDescription = "Callback Executed"
    private let testRequestDomain = "https://httpbin.org/post"
    private let testPurposeKey = "HighAccuracyLocationRequest"

    override func setUp() {
        super.setUp()

        LocationLogger.timeoutInterval = 3

        locationLogger = LocationLogger(
            locationManager: testLocationManager,
            network: testNetwork
        )
    }

    override func tearDown() {
        testLocationManager.prepareForReuse()
        testNetwork.prepareForReuse()

        super.tearDown()
    }

    func test_requestLocationAuthorizationMethod_statusAuthorized() {
        testLocationManager.addMockAuthorization(.success(authorization: .authorizedWhenInUse))

        var testResult: TestAuthorizationResult?
        let expectedResult: TestAuthorizationResult = .success(.authorizedWhenInUse)

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.requestLocationAuthorization(callback: { result in
            testResult = result.mapTestError
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)
    }

    func test_requestLocationAuthorizationMethod_statusDenied() {
        testLocationManager.addMockAuthorization(.failure(error: LocationLoggerError.errorStatus(.denied)))

        var testResult: TestAuthorizationResult?
        let expectedResult: TestAuthorizationResult = .failure(TestError())

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.requestLocationAuthorization(callback: { result in
            testResult = result.mapTestError
            expectation.fulfill()
        })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)
    }

    @available(iOS 14, *)
    func test_requestLocationAuthorizationAndAccuracyMethod_statusAuthorized() {
        testLocationManager.addMockAuthorization(.success(authorization: .authorizedWhenInUse))

        var testResult: TestAuthorizationResult?
        let expectedResult: TestAuthorizationResult = .success(.authorizedWhenInUse)

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.requestLocationAuthorizationAndAccuracy(
            purposeKey: testPurposeKey,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)
    }

    @available(iOS 14, *)
    func test_requestLocationAuthorizationAndAccuracyMethod_statusDenied() {
        testLocationManager.addMockAuthorization(.failure(error: LocationLoggerError.errorStatus(.denied)))

        var testResult: TestAuthorizationResult?
        let expectedResult: TestAuthorizationResult = .failure(TestError())

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.requestLocationAuthorizationAndAccuracy(
            purposeKey: testPurposeKey,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            })

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)
    }

    func test_logMethod_timeout() {
        testLocationManager.authorizationStatus = .denied
        testNetwork.mockResponseDelayInSeconds = LocationLogger.timeoutInterval + 1
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .failure(TestError())

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)
    }

    func test_logMethod_statusDenied_emptyData() {
        testLocationManager.authorizationStatus = .denied
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(nil)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 0,
            locationLon: 0,
            timestamp: 12345,
            extraText: "extraText"
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            extraText: "extraText",
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusDenied_validData() {
        let mockData = "data".data(using: .utf8)

        testLocationManager.authorizationStatus = .denied
        testNetwork.addMockResponse(.success(data: mockData))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(mockData)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 0,
            locationLon: 0,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusDenied_invalidData() {
        testLocationManager.authorizationStatus = .denied
        testNetwork.addMockResponse(.failure(error: .init(afError: .explicitlyCancelled, jsonData: nil)))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .failure(TestError())
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 0,
            locationLon: 0,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusAuthorized_validLocation() {
        let mockLocation = CLLocation(latitude: 10, longitude: 10)

        testLocationManager.authorizationStatus = .authorizedWhenInUse
        testLocationManager.addMockLocation(.success(location: mockLocation))
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(nil)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 10,
            locationLon: 10,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusAuthorized_invalidLocation() {
        testLocationManager.authorizationStatus = .authorizedWhenInUse
        testLocationManager.addMockLocation(.failure(error: LocationLoggerError.unknownCLError))
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(nil)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 0,
            locationLon: 0,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusNotDetermined_validLocation() {
        let mockLocation = CLLocation(latitude: 10, longitude: 10)

        testLocationManager.addMockAuthorization(.success(authorization: .authorizedWhenInUse))
        testLocationManager.addMockLocation(.success(location: mockLocation))
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(nil)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 10,
            locationLon: 10,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }

    func test_logMethod_statusNotDetermined_invalidLocation() {
        testLocationManager.addMockAuthorization(.success(authorization: .authorizedWhenInUse))
        testLocationManager.addMockLocation(.failure(error: LocationLoggerError.unknownCLError))
        testNetwork.addMockResponse(.success(data: nil))

        var testResult: TestLogResult?
        let expectedResult: TestLogResult = .success(nil)
        let expectedRequest = LogNetworkRequest(
            requestDomain: testRequestDomain,
            locationLat: 0,
            locationLon: 0,
            timestamp: 12345,
            extraText: ""
        )

        let expectation = self.expectation(description: testExpectationDescription)
        locationLogger.log(
            requestDomain: testRequestDomain,
            timestamp: 12345,
            callback: { result in
                testResult = result.mapTestError
                expectation.fulfill()
            }
        )

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertEqual(testResult, expectedResult)

        let testRequest = testNetwork.receivedNetworkRequests.first as? LogNetworkRequest
        XCTAssertTrue(testRequest == expectedRequest)
    }
}
