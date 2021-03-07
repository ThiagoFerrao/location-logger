import Foundation
import Alamofire

struct NetworkError: Error {
    let afError: AFError
    let jsonData: Data?
}
