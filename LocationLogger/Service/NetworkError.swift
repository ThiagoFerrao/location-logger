import Foundation
import Alamofire

public struct NetworkError: Error {
    public let afError: AFError
    public let jsonData: Data?
}
