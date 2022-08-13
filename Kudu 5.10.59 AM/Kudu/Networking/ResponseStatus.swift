import Foundation

struct EmptyError: Error {
    var title = ""
}

struct ResponseStatus {
    var code: Int
    var msg: String
    var errorObject: DecodingError?
    init(code: Int = 0, msg: String = "", errorObject: DecodingError? = nil) {
        self.code = code
        self.msg = msg
        if errorObject != nil {
            self.errorObject = errorObject
            debugPrint("Decoding Error : \(self.errorObject.debugDescription)")
        }
    }
}
