import Foundation
import Alamofire

struct NetworkError: Error {
    let afError: AFError
    let jsonData: Data?

    func errorContent<T: Decodable>() -> T? {
        guard let data = jsonData else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

extension Error {

    var asNetworkError: NetworkError? {
        self as? NetworkError
    }

    func asNetworkError(or defaultNetworkError: NetworkError) -> NetworkError {
        self as? NetworkError ?? defaultNetworkError
    }
}
