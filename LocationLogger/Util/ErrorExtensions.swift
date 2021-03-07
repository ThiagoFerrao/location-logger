import Foundation
import CoreLocation

extension Error {
    var isSkippableCLError: Bool {
        switch (self as? CLError)?.code {
        case .locationUnknown, .promptDeclined:
            return true

        default:
            return false
        }
    }
}
