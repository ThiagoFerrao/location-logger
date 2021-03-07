import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension Reactive where Base: CLLocationManager {

    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }

    var didChangeAuthorization: Observable<CLAuthorizationStatus> {
        return delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
            .map { response -> CLAuthorizationStatus? in
                guard let rawValue = response[1] as? Int32 else { return nil }
                return CLAuthorizationStatus(rawValue: rawValue)
            }
            .compactMap { $0 }
    }

    @available(iOS 14, *)
    var didChangeAuthorizationOrAccuracy: Observable<Void> {
        return delegate
            .methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)))
            .map { _ in () }
    }

    var didUpdateLocations: Observable<[CLLocation]> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
            .didUpdateLocationsSubject
            .asObservable()
    }

    var didFailWithError: Observable<Error> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
            .didFailWithErrorSubject
            .asObservable()
    }
}
