import Foundation
import CoreLocation
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
}
