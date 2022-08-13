import Foundation

// NS Error Extension
extension NSError {
    
    /// Method to check is network connection error comes
    ///
    /// - Returns: False when network connection error occured
    ///
    func isNetworkConnectionError() -> Bool {
        let networkErrors = [NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet]
        if self.domain == NSURLErrorDomain && networkErrors.contains(self.code) {
            return true
        }
        return false
    }
    
    convenience init(localizedDescription: String) {
        self.init(domain: "AppNetworkingError", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedDescription.capitalizedFirst])
    }
    
    convenience init(code: Int, localizedDescription: String) {
        self.init(domain: "AppNetworkingError", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription.capitalizedFirst])
    }
}
