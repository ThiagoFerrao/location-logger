import XCTest
import RxSwift
@testable import LocationLogger

extension LogNetworkRequest: Equatable {
    public static func == (lhs: LogNetworkRequest, rhs: LogNetworkRequest) -> Bool {
        return lhs.domain == rhs.domain &&
            lhs.method == rhs.method &&
            lhs.headers?.dictionary == rhs.headers?.dictionary &&
            lhs.parameters?["lat"] as? Double == rhs.parameters?["lat"] as? Double &&
            lhs.parameters?["lon"] as? Double == rhs.parameters?["lon"] as? Double &&
            lhs.parameters?["time"] as? Double == rhs.parameters?["time"] as? Double &&
            lhs.parameters?["ext"] as? String == rhs.parameters?["ext"] as? String
    }
}

struct TestError: Error, Equatable { }

extension Result {
    var mapTestError: Result<Success, TestError> {
        return self.mapError { _ in TestError() }
    }
}
