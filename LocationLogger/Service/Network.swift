import Foundation
import Alamofire
import RxSwift

protocol Networking {
    func request(with networkRequest: NetworkRequest) -> Single<Void>
    func request(with networkRequest: NetworkRequest) -> Single<Data>
    func request<T: Decodable>(with networkRequest: NetworkRequest) -> Single<T>
}

final class Network: Networking {

    static let shared = Network()
    private init() { }

    private let session: Session = Session.default

    func request(with networkRequest: NetworkRequest) -> Single<Void> {
        return session.rx.request(with: networkRequest)
            .map { _ in () }
    }

    func request(with networkRequest: NetworkRequest) -> Single<Data> {
        return session.rx.request(with: networkRequest)
            .map { data in
                guard let resultData = data else {
                    throw NetworkError(
                        afError: .responseSerializationFailed(reason: .inputFileNil),
                        jsonData: nil
                    )
                }
                return resultData
            }
    }

    func request<T: Decodable>(with networkRequest: NetworkRequest) -> Single<T> {
        return session.rx.request(with: networkRequest)
            .map { data in
                guard let resultData = data else {
                    throw NetworkError(
                        afError: .responseSerializationFailed(reason: .inputFileNil),
                        jsonData: nil
                    )
                }
                return try JSONDecoder().decode(T.self, from: resultData)
            }
    }
}

extension Session: ReactiveCompatible { }

extension Reactive where Base: Session {

    func request(with networkRequest: NetworkRequest) -> Single<Data?> {

        return .create(subscribe: { singleObserver -> Disposable in
            let request = base.request(
                networkRequest,
                method: networkRequest.method,
                parameters: networkRequest.parameters,
                encoding: networkRequest.encoding,
                headers: networkRequest.headers
            )
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    singleObserver(.success(response.data))

                case let .failure(error):
                    let networkError = NetworkError(afError: error, jsonData: response.data)
                    singleObserver(.failure(networkError))
                }
            }

            AppChecker.executeInDebug {
                request.cURLDescription { print($0) }
            }

            return Disposables.create {
                request.cancel()
            }
        })
    }
}
