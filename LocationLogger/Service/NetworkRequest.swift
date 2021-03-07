import Foundation
import Alamofire

protocol NetworkRequest: URLConvertible {
    var domain: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

extension NetworkRequest {
    func asURL() throws -> URL {
        return try URL(string: domain).unwrapOrThrow()
    }
}
