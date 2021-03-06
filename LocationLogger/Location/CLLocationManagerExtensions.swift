import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension Reactive where Base: CLLocationManager {

    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return CLLocationManagerDelegateProxy.proxy(for: base)
    }

    var didChangeAuthorization: ControlEvent<CLAuthorizationStatus> {
        let source = delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { response -> CLAuthorizationStatus? in
                guard let rawValue = response[1] as? Int32 else { return nil }
                return CLAuthorizationStatus(rawValue: rawValue)
            }
            .compactMap { $0 }

        return ControlEvent(events: source)
    }

    @available(iOS 14, *)
    var didChangeAuthorizationOrAccuracy: ControlEvent<Void> {
        let source = delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)))
            .map { _ in () }

        return ControlEvent(events: source)
    }

    var didUpdateLocations: ControlEvent<[CLLocation]> {
        let source = delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { response in response[1] as? [CLLocation] }
            .compactMap { $0 }

        return ControlEvent(events: source)
    }

    var didFailWithError: ControlEvent<Error> {
        let source = delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
            .map { response in response[1] as? Error }
            .compactMap { $0 }

        return ControlEvent(events: source)
    }
}
