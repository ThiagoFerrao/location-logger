import Foundation
import CoreLocation
import RxSwift

protocol LocationManaging {
    var authorizationStatus: CLAuthorizationStatus { get }
    func requestLocation() -> Observable<CLLocation>
    func requestAuthorization() -> Observable<CLAuthorizationStatus>
    @available(iOS 14, *)
    func requestAuthorizationAndAccuracy(purposeKey: String) -> Observable<CLAuthorizationStatus>
}

final class LocationManager: LocationManaging {

    static let shared = LocationManager()
    internal init() { }

    var authorizationStatus: CLAuthorizationStatus {
        if #available(iOS 14, *) {
            return CLLocationManager().authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }

    func requestLocation() -> Observable<CLLocation> {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest

        let locationObservable: Observable<CLLocation> = manager.rx.didUpdateLocations
            .map { try $0.last.unwrapOrThrow() }
            .catch { _ in .error(LocationLoggerError.unknownCLError) }

        let errorObservable: Observable<CLLocation> = manager.rx.didFailWithError
            .filter { !$0.isSkippableCLError }
            .flatMap { Observable.error($0) }

        return Observable.merge(locationObservable, errorObservable)
            .do(onSubscribe: { manager.requestLocation() })
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
            .flatMap { $0.deniedAuthorizationAsError }
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
            .flatMap { $0.deniedAuthorizationAsError }
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
            DispatchQueue.main.async {
                manager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: purposeKey)
            }

        default:
            return
        }
    }
}
