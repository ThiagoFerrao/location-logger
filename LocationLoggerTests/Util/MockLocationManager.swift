import Foundation
import CoreLocation
import RxSwift
@testable import LocationLogger

final class MockLocationManager: LocationManaging {

    var authorizationStatus = CLAuthorizationStatus.notDetermined
    private var mockLocationResposeList: [MockLocationReponse] = []
    private var mockAuthorizationResposeList: [MockAuthorizationReponse] = []

    static let shared = MockLocationManager()
    private init() { }

    func addMockLocation(_ mockReponse: MockLocationReponse) {
        mockLocationResposeList.insert(mockReponse, at: 0)
    }

    func addMockAuthorization(_ mockReponse: MockAuthorizationReponse) {
        mockAuthorizationResposeList.insert(mockReponse, at: 0)
    }

    func prepareForReuse() {
        authorizationStatus = .notDetermined
        mockLocationResposeList.removeAll()
        mockAuthorizationResposeList.removeAll()
    }

    func requestLocation() -> Observable<CLLocation> {
        return .create { [weak self] observer -> Disposable in
            let mockResponse = self?.mockLocationResposeList.popLast()

            switch mockResponse {
            case let .success(location):
                observer.onNext(location)
            case let .failure(error):
                observer.onError(error)
            case .none:
                break
            }

            return Disposables.create()
        }
    }

    func requestAuthorization() -> Observable<CLAuthorizationStatus> {
        return .create { [weak self] observer -> Disposable in
            let mockResponse = self?.mockAuthorizationResposeList.popLast()

            switch mockResponse {
            case let .success(location):
                observer.onNext(location)
            case let .failure(error):
                observer.onError(error)
            case .none:
                break
            }

            return Disposables.create()
        }
    }

    func requestAuthorizationAndAccuracy(purposeKey: String) -> Observable<CLAuthorizationStatus> {
        return requestAuthorization()
    }
}

enum MockLocationReponse {
    case success(location: CLLocation)
    case failure(error: Error)
}

enum MockAuthorizationReponse {
    case success(authorization: CLAuthorizationStatus)
    case failure(error: Error)
}
