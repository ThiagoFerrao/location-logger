import Foundation

public class LocationLogger {

    public static let shared = LocationLogger()
    init() { }

    public static func log() {
        print("LocationLogger - log")
    }
}
