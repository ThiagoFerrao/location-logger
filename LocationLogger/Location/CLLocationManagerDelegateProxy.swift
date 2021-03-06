import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

final class CLLocationManagerDelegateProxy:
DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
CLLocationManagerDelegate, DelegateProxyType {

    private weak var locationManager: CLLocationManager?

    init(locationManager: ParentObject) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: CLLocationManagerDelegateProxy.self)
    }

    static func registerKnownImplementations() {
        self.register { CLLocationManagerDelegateProxy(locationManager: $0) }
    }
}
