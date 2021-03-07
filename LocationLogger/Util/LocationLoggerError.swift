import Foundation
import CoreLocation

public enum LocationLoggerError: Error {
    case unableToUnwrap
    case unknownCLError
    case errorStatus(CLAuthorizationStatus)
}
