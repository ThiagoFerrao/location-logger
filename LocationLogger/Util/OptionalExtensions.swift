import Foundation

extension Optional {
    func unwrapOrThrow() throws -> Wrapped {
        switch self {
        case let .some(value):
            return value

        case .none:
            throw LocationLoggerError.unableToUnwrap
        }
    }
}
