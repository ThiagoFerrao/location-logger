import Foundation
import Alamofire

protocol NetworkRequest: URLConvertible {
    var domain: String { get }
    var version: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

extension NetworkRequest {
    var headers: HTTPHeaders? { nil }
    var parameters: [String: Any]? { nil }
    var encoding: ParameterEncoding { URLEncoding.default }

    func asURL() throws -> URL {
        var url = try URL(string: domain).unwrapOrThrow()
        url.appendPathComponent(version)
        url.appendPathComponent(path)
        return url
    }
}
