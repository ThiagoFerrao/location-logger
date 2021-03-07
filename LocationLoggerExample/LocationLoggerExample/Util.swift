import UIKit
import CoreLocation
import LocationLogger

extension UIViewController {
    func presentAlert(with title: String, and message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}

extension Result where Success == Data {
    func descripton() -> String {
        switch self {
        case let .success(data):
            return String(decoding: data, as: UTF8.self)
        case let .failure(error):
            if let neError = error as? NetworkError  {
                return neError.afError.localizedDescription
            }
            return error.localizedDescription
        }
    }
}

extension Result where Success == CLAuthorizationStatus {
    func descripton() -> String {
        switch self {
        case let .success(status):
            return status.description
        case let .failure(error):
            if let llError = error as? LocationLoggerError  {
                return llError.description
            }
            return error.localizedDescription
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "CLAuthorizationStatus - notDetermined"
        case .restricted:
            return "CLAuthorizationStatus - restricted"
        case .denied:
            return "CLAuthorizationStatus - denied"
        case .authorizedAlways:
            return "CLAuthorizationStatus - authorizedAlways"
        case .authorizedWhenInUse:
            return "CLAuthorizationStatus - authorizedWhenInUse"
        default:
            return "CLAuthorizationStatus - unknown"
        }
    }
}

extension LocationLoggerError {
    var description: String {
        switch self {
        case .unableToUnwrap:
            return "LocationLoggerError - unableToUnwrap"
        case .unknownCLError:
            return "LocationLoggerError - unknownCLError"
        case let .errorStatus(status):
            return "LocationLoggerError - \(status.description)"
        }
    }
}
