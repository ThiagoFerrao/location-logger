import Foundation
import CoreLocation
import RxSwift

extension LocationLogger: ReactiveCompatible { }

extension Reactive where Base: LocationLogger {

    func requestCurrentUserLocation() -> Observable<CLLocation> {
        return base.locationManager.requestLocation()
            .observableSubscriptionConfig()
    }

    func requestLocationAuthorization() -> Observable<CLAuthorizationStatus> {
        return base.locationManager.requestAuthorization()
            .observableSubscriptionConfig()
    }

    @available(iOS 14, *)
    func requestLocationAuthorizationAndAccuracy(purposeKey: String) -> Observable<CLAuthorizationStatus> {
        return base.locationManager.requestAuthorizationAndAccuracy(purposeKey: purposeKey)
            .observableSubscriptionConfig()
    }

    func executeLogRequest(with networkRequest: LogNetworkRequest) -> Observable<Data> {
        return base.network.request(with: networkRequest).asObservable()
            .observableSubscriptionConfig()
    }

    func executeCallback<T>(callback: ((Result<T, Error>) -> Void)? = nil) -> AnyObserver<T> {
        return AnyObserver { event in
            switch event {
            case let .next(result):
                callback?(.success(result))

            case let .error(error):
                callback?(.failure(error))

            case .completed:
                return
            }
        }
    }
}

extension Optional where Wrapped: LocationLogger {
    func helperRequestCurrentUserLocation() -> Observable<CLLocation> {
        guard let owner =  self else {
            return .error(LocationLoggerError.unknownCLError)
        }
        return owner.rx.requestCurrentUserLocation()
    }

    func helperExecuteLogRequest(
        with networkRequest: LogNetworkRequest,
        andUpdate location: CLLocation
    ) -> Observable<Data> {
        guard let owner = self else {
            return .error(LocationLoggerError.unknownCLError)
        }
        var newNetworkRequest = networkRequest
        newNetworkRequest.updateParameters(with: location)
        return owner.rx.executeLogRequest(with: newNetworkRequest)
    }
}

extension ObservableType {
    func observableSubscriptionConfig() -> Observable<Element> {
        return self
            .subscribe(on: AppScheduler.background)
            .timeout(.seconds(LocationLogger.timeoutInterval), scheduler: AppScheduler.timer)
    }
}
