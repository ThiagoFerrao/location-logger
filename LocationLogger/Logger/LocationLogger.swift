import Foundation
import CoreLocation
import Alamofire
import RxSwift
import RxCocoa

/**
 LocationLogger is the singleton used to call the log functions that will register the user's geolocation
 to a chosen endpoint. It has other functions that will make it easy to request the user's authorization to use
 the location services at the most relevant time at your app.

 The LocationLogger framework will use the location services to retrive the user's geolocation, to do that
 it will request authorization to access the location data in the user's device. It's essential that the app that
 will use this framework add to its `Info.plist` the key `NSLocationWhenInUseUsageDescription` with a message that
 tells the users why the app is requesting access to theirs location information. In the case of apps that give support
 to devices with iOS14+, it is also recommended to add a key in the `NSLocationTemporaryUsageDescriptionDictionary`
 dictionary which will make the permission to temporarily use location services with full accuracy available for use.

 To call the single functions you need to use its shared singleton instance LocationLogger.shared.
 */
public final class LocationLogger {

    public typealias PermissionResult = Result<CLAuthorizationStatus, Error>
    public typealias RequestResult = Result<Data?, Error>

    /**
     The timeoutInterval value defines the amount of time in seconds that each LocationLogger's functions can
     take to complete its actions.
     */
    public static var timeoutInterval: Int = 10

    internal let locationManager: LocationManaging
    internal let network: Networking

    public static let shared = LocationLogger()
    internal init(
        locationManager: LocationManaging = LocationManager.shared,
        network: Networking = Network.shared
    ) {
        self.locationManager = locationManager
        self.network = network
    }

    /**
     Execute request to defined endpoint with the functions parameters as body. The body of the request will
     include the location of the user as `lat` and `lon`, the current timestamp as `time` and a extra text parameter
     as `ext`. If the authorization to use the location services wasn't requested yet, in the momment of the call to
     this function, it will be requested. In case of denied access to the location services or some error during
     the whole process to obtain the user's location, the parameters `lat` and `lon` will be equal to zero.

     - parameter requestDomain: Value of the domain with its path of the endpoint that will be called.
     - parameter timestamp: Value of the current timestamp included in the body of the request. If not assigned,
     the `NSDate().timeIntervalSince1970` will be used as default value.
     - parameter extraText: Value of an additional text that will be in the body of the request. If not assigned,
     a empty string will be used as default value.
     - parameter callback: Closure will be call with the payload retrived by the request to the defined endpoint
     or an error that may be cast to NetworkError.
     */
    public func log(
        requestDomain: String,
        timestamp: Double = NSDate().timeIntervalSince1970,
        extraText: String = "",
        callback: ((RequestResult) -> Void)? = nil
    ) {
        let networkRequest = LogNetworkRequest(
            requestDomain: requestDomain,
            timestamp: timestamp,
            extraText: extraText
        )

        switch locationManager.authorizationStatus {
        case .notDetermined:
            _ = rx
                .requestLocationAuthorization()
                .flatMap { [weak self] _ in
                    self.helperRequestCurrentUserLocation()
                }
                .catchAndReturn(.init(latitude: 0, longitude: 0))
                .flatMap { [weak self] location in
                    self.helperExecuteLogRequest(with: networkRequest, andUpdate: location)
                }
                .subscribe { [weak self] event in
                    self?.rx.executeCallback(callback: callback).on(event)
                }

        case .authorizedAlways, .authorizedWhenInUse:
            _ = rx
                .requestCurrentUserLocation()
                .catchAndReturn(.init(latitude: 0, longitude: 0))
                .flatMap { [weak self] location in
                    self.helperExecuteLogRequest(with: networkRequest, andUpdate: location)
                }
                .subscribe { [weak self] event in
                    self?.rx.executeCallback(callback: callback).on(event)
                }

        default:
            _ = rx
                .executeLogRequest(with: networkRequest)
                .subscribe { [weak self] event in
                    self?.rx.executeCallback(callback: callback).on(event)
                }
        }
    }

    /**
     Request user's authorization to use the location services. It is advisable to request this authorization before
     using the log function with geolocation automatically retrived by the LocationLogger framework.

     - parameter callback: Closure will be call with the authorization status or an error that may be cast
     to LocationLoggerError.
     */
    public func requestLocationAuthorization(
        callback: ((PermissionResult) -> Void)? = nil
    ) {
        _ = rx
            .requestLocationAuthorization()
            .subscribe { [weak self] event in
                self?.rx.executeCallback(callback: callback).on(event)
            }
    }

    /**
     Request user's authorization to use the location services and also request the best location accuracy in
     devices with iOS 14 or more. It is advisable to request this authorization before using the log function with
     geolocation automatically retrived by the LocationLogger framework.

     - parameter purposeKey: The purposeKey must be a key in the NSLocationTemporaryUsageDescriptionDictionary
     dictionary of the app's Info.plist file with a reason for accessing location data with full accuracy.
     A invalid key will make the authorization request fails.
     - parameter callback: Closure will be call with the authorization status or an error that may be cast
     to LocationLoggerError.
     */
    @available(iOS 14, *)
    public func requestLocationAuthorizationAndAccuracy(
        purposeKey: String,
        callback: ((PermissionResult) -> Void)? = nil
    ) {
        _ = rx
            .requestLocationAuthorizationAndAccuracy(purposeKey: purposeKey)
            .subscribe { [weak self] event in
                self?.rx.executeCallback(callback: callback).on(event)
            }
    }
}
