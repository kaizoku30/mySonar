import Foundation

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            printDebug(error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? CommonStrings.emptyString
    }
}
