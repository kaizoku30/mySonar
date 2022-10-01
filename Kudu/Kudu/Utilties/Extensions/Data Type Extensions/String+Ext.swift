import Foundation
import UIKit

extension UILabel {

        func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
            let readMoreText: String = trailingText + moreText

            let lengthForVisibleString: Int = self.vissibleTextLength
            let mutableString: String = self.text!
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
            let readMoreLength: Int = (readMoreText.count)
            let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font!])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }

        var vissibleTextLength: Int {
            let font: UIFont = self.font
            let mode: NSLineBreakMode = self.lineBreakMode
            let labelWidth: CGFloat = self.frame.size.width
            let labelHeight: CGFloat = self.frame.size.height
            let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key: Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                    }
                } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key: Any], context: nil).size.height <= labelHeight
                return prev
            }
            return self.text!.count
        }
    }

extension String {
    func htmlAttributed(family: String?, size: CGFloat, color: UIColor = .black) -> NSAttributedString? {
        let colorString = color == .black ? "#000000" : "#FFFFFF"
        
            do {
                let htmlCSSString = "<style>" +
                    "html *" +
                    "{" +
                    "font-size: \(size)px !important;" +
                    "color: \(colorString) !important;" +
                    "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
                "}</style> \(self)"

                guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                    return nil
                }

                return try NSAttributedString(data: data,
                                              options: [.documentType: NSAttributedString.DocumentType.html,
                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                              documentAttributes: nil)
            } catch {
                print("error: ", error)
                return nil
            }
        }
}

extension String {
    
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func startsWith(string: String) -> Bool {
        guard let range = range(of: string, options: [.caseInsensitive]) else {
            return false
        }
        return range.lowerBound == startIndex
    }
}

extension String {
    
    func trunc(length: Int) -> String {
        return String(self.prefix(length))
     }
    
    func replaceCharacter(inString: String, _ atIndex: Int, _ newChar: Character) -> String {
        var chars = Array(inString)     // gets an array of characters
        chars[atIndex] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    /// Removes all spaces from the string
    var removeSpaces: String {
        return self.replacingOccurrences(of: CommonStrings.whiteSpace, with: CommonStrings.emptyString)
    }
    
    /// Return Int Value
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var doubleValue: Double {
        return Double(self) ?? 0.0
    }
    
    /// Removes all HTML Tags from the string
    var removeHTMLTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: CommonStrings.emptyString, options: .regularExpression, range: nil)
    }
    
    /// Removes leading and trailing white spaces from the string
    var byRemovingLeadingTrailingWhiteSpaces: String {
        
        let spaceSet = CharacterSet.whitespaces
        return self.trimmingCharacters(in: spaceSet)
    }
    
    mutating func appendLeadingTrailingText(leadingText: String, trailingText: String) {
        self = leadingText + self + trailingText
    }
    
    /// Method to check that string is emoji
    func isEmojiString() -> Bool {
        if !self.canBeConverted(to: String.Encoding.ascii) {
            return true
        }
        return false
    }
    
    func mandatoryChecksForWrongInputs(fullText: String) -> Bool {
        return self.isInputEmptyString(fullText: fullText) || self.isInputDoubleDots(fullText: fullText) || self.isInputDoubleWhiteSpace(fullText: fullText)
    }
    
    func isInputEmptyString(fullText: String) -> Bool {
        if fullText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || self == CommonStrings.whiteSpace) {
            return true
        }
        return false
    }
    
    func isInputDoubleWhiteSpace(fullText: String) -> Bool {
        if (fullText.last == " ") && self == CommonStrings.whiteSpace {
            return true
        }
        return false
    }
    
    func isInputDoubleDots(fullText: String) -> Bool {
        if (fullText.last == ".") && self == CommonStrings.dot {
            return true
        }
        return false
    }
    
    func hasSpecialCharacters() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)).isNotNil {
                return true
            }
            
        } catch {
            printDebug(error.localizedDescription)
            return false
        }
        
        return false
    }
    
    func hasUperChar() -> Bool {
        let capitalLetterRegEx  = ".*[A-Z]+.*"
        let textTest = NSPredicate(format: CommonStrings.predicateMatcher, capitalLetterRegEx)
        let result = textTest.evaluate(with: self)
        return result
    }
    
    func hasLowerChar() -> Bool {
        let smallLetterRegEx  = ".*[a-z]+.*"
        let textTest = NSPredicate(format: CommonStrings.predicateMatcher, smallLetterRegEx)
        let result = textTest.evaluate(with: self)
        return result
    }
    
    func hasNumbers() -> Bool {
        let smallLetterRegEx  = ".*[0-9]+.*"
        let textTest = NSPredicate(format: CommonStrings.predicateMatcher, smallLetterRegEx)
        let result = textTest.evaluate(with: self)
        return result
    }
    
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: CommonStrings.whiteSpace)
    }
    
    public func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: CommonStrings.emptyString)
        } else {
            return self
        }
    }
    /// Returns 'true' if the string is any (file, directory or remote etc) url otherwise returns 'false'
    var isAnyUrl: Bool {
        return (URL(string: self) != nil)
    }
    
    var isNumberString: Bool {
        let spaceSet = CharacterSet.decimalDigits.inverted
        return (self.rangeOfCharacter(from: spaceSet) == nil)
    }
    
    var isAlphabetsString: Bool {
        let spaceSet = CharacterSet.letters.inverted
        return (self.rangeOfCharacter(from: spaceSet) == nil)
    }
    
    /// Returns the json object if the string can be converted into it, otherwise returns 'nil'
    var jsonObject: Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                printDebug(error.localizedDescription)
            }
        }
        return nil
    }
    
    /// Returns the base64Encoded string
    var base64Encoded: String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Returns the string decoded from base64Encoded string
    var base64Decoded: String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func heightOfText(_ width: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthOfText(_ height: CGFloat, font: UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.width
    }
    
    func textSize(withFont font: UIFont, boundingSize size: CGSize) -> CGSize {
        let mutableParagraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: mutableParagraphStyle]
        let tempStr = NSString(string: self)
        
        let rect: CGRect = tempStr.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let height = ceilf(Float(rect.size.height))
        let width = ceilf(Float(rect.size.width))
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    func localizedString(lang: String) -> String {
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        printDebug(path)
        let bundle = Bundle(path: path!)
        printDebug(bundle)
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: CommonStrings.emptyString, comment: CommonStrings.emptyString)
    }
    
    /// Returns 'true' if string contains the substring, otherwise returns 'false'
    func contains(s: String) -> Bool {
        return self.range(of: s) != nil ? true: false
    }
    
    /// Replaces occurances of a string with the given another string
    func replace(string: String, withString: String) -> String {
        return self.replacingOccurrences(of: string, with: withString, options: String.CompareOptions.literal, range: nil)
    }
    
    mutating func removeFirstElement() {
        if self.isEmpty {
            return
        }
        self.removeSubrange(self.startIndex...self.startIndex)
    }
    
    func getPriceFromString() -> String {
        let chars = Set("1234567890.")
        return String(self.filter { chars.contains($0) })
    }
        
    func checkIfValid(_ validityExression: ValidityExression) -> Bool {
        
        if validityExression == .password {
            if !NSPredicate(format: CommonStrings.predicateMatcher, ValidityExression.capitalLetter.rawValue).evaluate(with: self) {
                return false
            }
            if !NSPredicate(format: CommonStrings.predicateMatcher, ValidityExression.specialCharacter.rawValue).evaluate(with: self) {
                return false
            }
            return true
            
        } else {
            let regEx = validityExression.rawValue
            let test = NSPredicate(format: CommonStrings.predicateMatcher, regEx)
            
            return test.evaluate(with: self)
        }
        
    }
    
    func checkIfInvalid(_ validityExression: ValidityExression) -> Bool {
        return !self.checkIfValid(validityExression)
    }
    
    /// Capitalize the very first letter of the sentence.
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        var result = self
        let substr1 = String(self[startIndex]).uppercased()
        result.replaceSubrange(...startIndex, with: substr1)
        return result
    }
    
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce(CommonStrings.emptyString) {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + CommonStrings.whiteSpace + String($1))
            } else {
                return $0 + String($1)
            }
        }
    }
    
    func stringByAppendingPathComponent(path: String) -> String {
        
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    
    func getLastNSubString(number: Int) -> String {
        return String(self.suffix(number))
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    public var isAlphaNumeric: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        let comps = components(separatedBy: .alphanumerics)
        return comps.joined(separator: CommonStrings.emptyString).count == 0 && hasLetters && hasNumbers
    }
    
    public func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
    
    public func starts(with prefix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasPrefix(prefix.lowercased())
        }
        return hasPrefix(prefix)
    }
}

extension String {
    
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? self.removeHTMLTags
    }
}

extension String.Index {
    func distance<S: StringProtocol>(in string: S) -> Int {
        string.distance(from: string.startIndex, to: self)
    }
}

enum ValidityExression: String {
    
    case userName = "^[a-zA-z]{1,}+[a-zA-z0-9!@#$%&*]{2,15}"
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case mobileNumber = "^[0-9]{6,14}$"
    case password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$!%*?&#])[A-Za-z$@$!%*?&#]{8,}"
    case name = "^[a-zA-Z]{2,15}"
    case webUrl = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    case interest = "/  +/g"
    case capitalLetter = ".*[A-Z]+.*"
    case smallLetter = ".*[a-z]+.*"
    case specialCharacter  = ".*[!&^%$#@()/]+.*"
}

extension String {
    func indices(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let i = distance(from: startIndex,
                             to: range.lowerBound)
            indices.append(i)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                                        break
            }
            position = index(after: after)
        }
        return indices
    }
}

extension String {
    
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    func containsEmoji() -> Bool {
        var isEmoji = false
        
        for scalar in unicodeScalars {
           
                switch scalar.value {
                case 0x1F600...0x1F64F, // Emoticons
                                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                                0x1F680...0x1F6FF, // Transport and Map
                                0x2600...0x26FF,   // Misc symbols
                                0x2700...0x27BF,   // Dingbats
                                0xFE00...0xFE0F,   // Variation Selectors
                                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                                0x1F1E6...0x1F1FF: // Flags
                    isEmoji = true
                default:
                    debugPrint("")
                }
            
        }
        
        return isEmoji
    }
    
    var isValidUrlByRegex: Bool {
            let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
            let predicate = NSPredicate(format: CommonStrings.predicateMatcher, argumentArray: [regEx])
            let predicatedValue: Bool = predicate.evaluate(with: self)
            var isContainingAllUnicode: Bool = true
            /// Checking the non english characters in the link
            _ = self.unicodeScalars.map({ (char) in
                if !char.isASCII {
                    isContainingAllUnicode = false
                }
            })
            return predicatedValue && isContainingAllUnicode
    }
    
    var isValidPrice: Bool {
            let regEx = "^\\d{0,6}(\\.\\d{1,2})?$"
            let predicate = NSPredicate(format: CommonStrings.predicateMatcher, regEx)
            return predicate.evaluate(with: self)
    }
    
    func canOpenURL() -> Bool {
        if let url = URL(string: self) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    func emojiFlag() -> String? {
        let code = self.uppercased()
        
        guard Locale.isoRegionCodes.contains(code) else {
            return nil
        }
        
        var flagString = ""
        for s in code.unicodeScalars {
            guard let scalar = UnicodeScalar(127397 + s.value) else {
                continue
            }
            flagString.append(String(scalar))
        }
        return flagString
    }
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
    
    func setColorAndFontForText(textForAttribute: String, withColor color: UIColor, withFont font: UIFont) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        self.addAttribute(NSAttributedString.Key.font, value: font, range: range)
    }
    
}

extension String {
    func getAttributedString(font: UIFont, color: UIColor, underline: Bool = false) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.underlineStyle: underline ? 1 : 0]
        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: self, attributes: attrs)
        attributedString.append(buttonTitleStr)
        return attributedString
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if detector.isNil {
            return false }
        if let match = detector!.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
}

extension String {

    private func matches(pattern: String) -> Bool {
        let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive])
        if regex.isNil {
            return false }
        return regex!.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: utf16.count)) != nil
    }

    func isInterntValidURL() -> Bool {
        guard let url = URL(string: self) else { return false }
        if !UIApplication.shared.canOpenURL(url) {
            return false
        }

        let urlPattern = "^(http|https|ftp)\\://([a-zA-Z0-9\\.\\-]+(\\:[a-zA-Z0-9\\.&amp;%\\$\\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\\-]+\\.)*[a-zA-Z0-9\\-]+\\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\\:[0-9]+)*(/($|[a-zA-Z0-9\\.\\,\\?\\'\\\\\\+&amp;%\\$#\\=~_\\-]+))*$"
        return self.matches(pattern: urlPattern)
    }
}

extension String {
    func getWidth(font: UIFont) -> CGFloat {
           let fontAttributes = [NSAttributedString.Key.font: font]
           let myText = self
           let size = (myText as NSString).size(withAttributes: fontAttributes)
           return size.width
    }
}

extension String {
  var urlEncoded: String {
    var charset: CharacterSet = .urlQueryAllowed
    charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
    return self.addingPercentEncoding(withAllowedCharacters: charset)!
  }
    
    var urlQueryStringParameters: [String: String] {
        // breaks apart query string into a dictionary of values
        var params = [String: String]()
        let items = self.split(separator: "&")
        for item in items {
          let combo = item.split(separator: "=")
          if combo.count == 2 {
            let key = "\(combo[0])"
            let val = "\(combo[1])"
            params[key] = val
          }
        }
        return params
      }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
