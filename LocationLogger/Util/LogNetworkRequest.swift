import Foundation
import CoreLocation
import Alamofire

struct LogNetworkRequest: NetworkRequest {
    let domain: String
    var parameters: [String: Any]?

    let method: HTTPMethod = .post
    let headers: HTTPHeaders? = .init(["Accept": "application/json"])
    let encoding: ParameterEncoding = URLEncoding.default

    init(
        requestDomain: String,
        locationLat: Double = 0,
        locationLon: Double = 0,
        timestamp: Double,
        extraText: String
    ) {
        self.domain = requestDomain
        self.parameters = [
            "lat": locationLat,
            "lon": locationLon,
            "time": timestamp,
            "ext": extraText
        ]
    }

    mutating func updateParameters(with location: CLLocation) {
        parameters?.updateValue(location.coordinate.latitude, forKey: "lat")
        parameters?.updateValue(location.coordinate.longitude, forKey: "lon")
    }
}
