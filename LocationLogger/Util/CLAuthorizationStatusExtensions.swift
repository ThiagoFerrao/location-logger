import Foundation
import CoreLocation
import RxSwift

extension CLAuthorizationStatus {
    var deniedAuthorizationAsError: Observable<CLAuthorizationStatus> {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return .just(self)

        default:
            return .error(LocationLoggerError.errorStatus(self))
        }
    }
}
