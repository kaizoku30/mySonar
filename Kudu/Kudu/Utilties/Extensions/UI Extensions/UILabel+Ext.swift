import Foundation
import UIKit

extension UILabel {
    
    /// Method to set line spacing in label
    /// - Parameters:
    ///   - lineSpacing: CGFloat value for line spacing
    ///   - lineHeightMultiple: CGFloat value for line height multiplication
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        // (Swift 4.1 and 4.0) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.attributedText = attributedString
    }
    
    /// Method to add underline the in label
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
    
    /// Method to set attributed font text with color
    /// - Parameters:
    ///   - text: Text to be attributed
    ///   - textColor: text color
    func attributedFontColorForText(text: String, textColor: UIColor) {

        //self.textColor = UIColor.black
        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: text)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
        // attribute.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: range)
        self.attributedText = attribute
    }

    /// Method to set attributed font text with color
    /// - Parameters:
    ///   - text: Text to be attributed
    ///   - textColor: text color
    func attributedFontForText(text: String, textFont: UIFont) {

        //  self.textColor = UIColor.black
        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: text)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }

        attribute.addAttribute(NSAttributedString.Key.font, value: textFont, range: range)
        // attribute.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: range)
        self.attributedText = attribute
    }

    func attributedFontAndColorForText(atributedText: String, textFont: UIFont, textColor: UIColor) {

        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        //let range = main_string.range(of: atributedText)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }

        if let regularExpression = try? NSRegularExpression(pattern: atributedText, options: .caseInsensitive) {
            let matchedResults = regularExpression.matches(in: labelString, options: [], range: NSRange(location: 0, length: labelString.count))
            for matched in matchedResults {
                attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: matched.range)

                attribute.addAttribute(NSAttributedString.Key.font, value: textFont, range: matched.range)

            }
        }

        // attribute.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: range)
        self.attributedText = attribute
    }

    func AttributedFontColorForTextBackwards(text: String, textColor: UIColor) {

        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: text, options: NSString.CompareOptions.backwards)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)

        self.attributedText = attribute

    }

    // for multiAttributed Text in single text
    func multiAttributedFontAndColorForText(atributedText: String, textFont: UIFont, textColor: UIColor) {

        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: atributedText)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }

        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)

        attribute.addAttribute(NSAttributedString.Key.font, value: textFont, range: range)

        // attribute.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: range)
        self.attributedText = attribute
    }

    func AttributedBaseLineFontColorForText(text: String, textColor: UIColor) {

        //self.textColor = UIColor.black
        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: text)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
        attribute.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
        attribute.addAttribute(NSAttributedString.Key.underlineColor, value: textColor, range: range)
        self.attributedText = attribute
    }

    func AttributedTextBackgroundColorForText(text: String, textColor: UIColor) {

        //self.textColor = UIColor.black
        guard let labelString = self.text else { return }

        let main_string = labelString as NSString
        let range = main_string.range(of: text)

        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }
        attribute.addAttribute(NSAttributedString.Key.backgroundColor, value: textColor, range: range)
        // attribute.addAttribute(NSBaselineOffsetAttributeName, value: 0, range: range)
        self.attributedText = attribute
    }
    
    func AttributedBaseLineColorForText(text: String, lineColor: UIColor) {
        
        //self.textColor = UIColor.black
        guard let labelString = self.text else { return }
        
        let main_string = labelString as NSString
        let range = main_string.range(of: text)
        
        var  attribute = NSMutableAttributedString.init(string: main_string as String)
        if let labelAttributedString = self.attributedText {
            attribute = NSMutableAttributedString.init(attributedString: labelAttributedString)
        }
        attribute.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
        attribute.addAttribute(NSAttributedString.Key.underlineColor, value: lineColor, range: range)
        self.attributedText = attribute
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
    
    var numberOfVisibleLinesInCGFloat: CGFloat {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let textHeight = sizeThatFits(maxSize).height
        let lineHeight = font.lineHeight
        return (ceil(textHeight / lineHeight))
    }
    
    func addCharacterSpacing(kernValue: Double = 1.15) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

extension UILabel {
    
//    var vissibleTextLength: Int {
//        let font: UIFont = self.font
//        let mode: NSLineBreakMode = self.lineBreakMode
//        let labelWidth: CGFloat = self.frame.size.width
//        let labelHeight: CGFloat = self.frame.size.height
//        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
//        
//        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
//        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key: Any])
//        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
//        
//        if boundingRect.size.height > labelHeight {
//            var index: Int = 0
//            var prev: Int = 0
//            let characterSet = CharacterSet.whitespacesAndNewlines
//            repeat {
//                prev = index
//                if mode == NSLineBreakMode.byCharWrapping {
//                    index += 1
//                } else {
//                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
//                }
//            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key: Any], context: nil).size.height <= labelHeight
//            return prev
//        }
//        return self.text!.count
//    }
}

extension UILabel {
    
    func resizeIfNeeded() -> CGFloat? {
        guard let text = text, !text.isEmpty else { return nil }
        
        if isTruncated {
            numberOfLines = 0
            sizeToFit()
            return frame.height
        }
        return nil
    }

    var isTruncated: Bool {

        guard let labelText = text, let _font = self.font else {
            return false
        }
        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin, attributes: [.font: _font], context: nil).size

        return labelTextSize.height > bounds.size.height
    }
}

extension String {
    func createLabelAndCheckTruncation(width: CGFloat, font: UIFont, numberOfLines: Int) -> Bool {
        let label: UILabel = UILabel(frame: CGRect(x: 24, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.frame.origin = CGPoint.zero
        label.size.width = width
        label.numberOfLines = numberOfLines
        label.font = font
        label.text = self
        label.sizeToFit()
        return label.isTruncated
    }
}
