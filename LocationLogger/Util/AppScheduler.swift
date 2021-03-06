import Foundation
import RxSwift

final class AppScheduler {
    static var background: ImmediateSchedulerType {
        if AppChecker.isRunningTests {
            return MainScheduler.instance
        } else {
            return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
        }
    }
}
