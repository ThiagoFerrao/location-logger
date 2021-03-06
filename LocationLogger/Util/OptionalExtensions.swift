import Foundation

enum OptionalError: Error {
    case unableToUnwrap
}

extension Optional {
    func unwrapOrThrow() throws -> Wrapped {
        switch self {
        case let .some(value):
            return value
        case .none:
            throw OptionalError.unableToUnwrap
        }
    }
}
