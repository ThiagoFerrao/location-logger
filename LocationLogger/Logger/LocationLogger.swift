import Foundation
import Alamofire
import RxSwift
import RxCocoa

public final class LocationLogger {

    public static let shared = LocationLogger()
    init() { }

    public func log(
        api: String,
        lat: Double = 0.0,
        lon: Double = 0.0,
        time: Int = 0, // epoch timestamp in seconds
        ext: String = "", // extra text payload
        callback: @escaping (Any) -> Void
    ) {
        let payload: [String: Any] = [
            "lat": lat,
            "lon": lon,
            "time": time,
            "ext": ext,
        ]

        // implement POST payload to API Server
        // callback should happen after POST
        return callback(payload)
    }
}
