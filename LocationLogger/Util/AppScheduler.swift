import Foundation
import RxSwift

final class AppScheduler {
    static var background: SchedulerType {
        if AppChecker.isRunningTests {
            return MainScheduler.instance
        } else {
            return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
        }
    }

    static var timer = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
}
