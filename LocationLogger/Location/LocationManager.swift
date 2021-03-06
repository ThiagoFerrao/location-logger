import Foundation
import CoreLocation
import RxSwift
import RxCocoa

typealias LocationResult = Result<CLLocation, CLError>

final class LocationManager {

    static let shared = LocationManager()
    private init() { }

    func requestLocation() -> Observable<LocationResult> {
        let manager = CLLocationManager()
        manager.requestLocation()

        let successObservable: Observable<LocationResult> = manager.rx.didUpdateLocations
            .map { locations in
                guard let lastLocation = locations.last else {
                    return .failure(CLError(.network))
                }
                return .success(lastLocation)
            }

        let failureObservable: Observable<LocationResult> = manager.rx.didFailWithError
            .map { error in
                guard let locationError = error as? CLError else {
                    return .failure(CLError(.network))
                }
                return .failure(locationError)
            }

        return Observable.merge(successObservable, failureObservable)
            .filter { result in
                guard case let .failure(locationError) = result, locationError.code == .locationUnknown else {
                    return true
                }
                return false
            }
            .take(1)
    }

    func requestAuthorization() -> Observable<CLAuthorizationStatus> {
        let manager = CLLocationManager()

        return manager.rx.didChangeAuthorization
            .startWith(CLLocationManager.authorizationStatus())
            .distinctUntilChanged()
            .do(onNext: { [weak self] status in
                guard let self = self else { return }
                self.requestAuthorizationIfNeeded(manager: manager, status: status)
            })
            .filter { $0 != .notDetermined }
            .catchAndReturn(CLLocationManager.authorizationStatus())
            .take(1)
    }

    @available(iOS 14, *)
    func requestAuthorizationAndAccuracy(purposeKey: String) -> Observable<CLAuthorizationStatus> {
        let manager = CLLocationManager()

        return manager.rx.didChangeAuthorizationOrAccuracy
            .startWith(())
            .map { _ in manager.authorizationStatus }
            .distinctUntilChanged()
            .do(onNext: { [weak self] status in
                guard let self = self else { return }
                self.requestAuthorizationIfNeeded(manager: manager, status: status)
                self.requestBetterAccuracyIfNeeded(manager: manager, purposeKey: purposeKey)
            })
            .filter { $0 != .notDetermined }
            .catchAndReturn(manager.authorizationStatus)
            .take(1)
    }

    private func requestAuthorizationIfNeeded(manager: CLLocationManager, status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            DispatchQueue.main.async {
                manager.requestWhenInUseAuthorization()
            }

        default:
            return
        }
    }

    @available(iOS 14, *)
    private func requestBetterAccuracyIfNeeded(manager: CLLocationManager, purposeKey: String) {
        switch manager.accuracyAuthorization {
        case .reducedAccuracy:
            manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)

        default:
            return
        }
    }
}
