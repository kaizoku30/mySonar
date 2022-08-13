import Foundation
import Alamofire

class CustomRequestRetrier: RequestAdapter, RequestRetrier {
    var endpoint: Endpoint
    
    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let modifiedUrlRequest = urlRequest
        _ = urlRequest.value(forHTTPHeaderField: "Authorization")
        completion(.success(modifiedUrlRequest))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("CustomRequestRetrier should retry request: \(request)")
        guard request.retryCount <= 3 else {
            print("CustomRequestRetrier did already retry 3 times. No more!!!")
            completion(.doNotRetry)
            return
        }
        print("CustomRequestRetrier should retry request completion")
        completion(.retryWithDelay(3))
    }
}

class RefreshingTokenRequestRetrier: RequestAdapter, RequestRetrier {
    var endpoint: Endpoint
    
    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let modifiedUrlRequest = urlRequest
//        let currentToken = urlRequest.value(forHTTPHeaderField: "Authorization")
        completion(.success(modifiedUrlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("RefreshingTokenRequestRetrier should retry request: \(request)")
        print("RefreshingTokenRequestRetrier should retry request completion")
        completion(.retryWithDelay(7))
    }
}
