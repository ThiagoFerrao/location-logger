import Foundation

final class AppChecker {
    static var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    static func executeInDebug(handler: (() -> Void)) {
        if isDebug {
            handler()
        }
    }
}
