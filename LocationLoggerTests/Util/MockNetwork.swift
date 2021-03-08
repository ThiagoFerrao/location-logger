import Foundation
import RxSwift
@testable import LocationLogger

final class MockNetwork: Networking {

    var mockResponseDelayInSeconds: Int = 0
    var receivedNetworkRequests: [NetworkRequest] = []
    private var mockResposeList: [MockNetworkReponse] = []

    static let shared = MockNetwork()
    private init() { }

    func addMockResponse(_ mockReponse: MockNetworkReponse) {
        mockResposeList.insert(mockReponse, at: 0)
    }

    func prepareForReuse() {
        mockResponseDelayInSeconds = 0
        receivedNetworkRequests.removeAll()
        mockResposeList.removeAll()
    }

    func request(with networkRequest: NetworkRequest) -> Single<Data?> {
        receivedNetworkRequests.append(networkRequest)

        return Single.create(subscribe: { [weak self] singleObserver -> Disposable in
            let mockResponse = self?.mockResposeList.popLast()

            switch mockResponse {
            case let .success(data):
                singleObserver(.success(data))
            case let .failure(error):
                singleObserver(.failure(error))
            case .none:
                break
            }

            return Disposables.create()
        })
        .delay(.seconds(mockResponseDelayInSeconds), scheduler: AppScheduler.background)
    }
}

enum MockNetworkReponse {
    case success(data: Data?)
    case failure(error: NetworkError)
}
