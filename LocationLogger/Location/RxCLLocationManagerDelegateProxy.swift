import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

final class RxCLLocationManagerDelegateProxy:
DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
CLLocationManagerDelegate, DelegateProxyType {

    private weak var locationManager: CLLocationManager?

    init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }

    internal let didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    internal let didFailWithErrorSubject = PublishSubject<Error>()

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager?(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager?(manager, didFailWithError: error)
        didFailWithErrorSubject.onNext(error)
    }

    deinit {
        self.didUpdateLocationsSubject.onCompleted()
        self.didFailWithErrorSubject.onCompleted()
    }
}
