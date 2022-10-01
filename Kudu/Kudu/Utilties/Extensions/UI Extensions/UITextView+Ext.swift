import UIKit

// MARK: - Methods
public extension UITextView {
    
    /// Scroll to the top of text view
    func scrollToTop() {
        let range = NSRange(location: 0, length: 1)
        scrollRangeToVisible(range)
    }
    
    /// Check Empty Text View
    func validate() -> Bool {
        guard let text =  self.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                return false
        }
        return true
    }
    
    /// Variable to get cursor offset
    var cursorOffset: Int? {
        guard let range = selectedTextRange else { return nil }
        return offset(from: beginningOfDocument, to: range.start)
    }
    
    /// Variable to get cursor index
    var cursorIndex: String.Index? {
        guard
            let location = cursorOffset,
            case let length = text.utf16.count-location
            else { return nil }
        return Range(.init(location: location, length: length), in: text)?.lowerBound
    }
    
    /// Variable to get cursor distance
    var cursorDistance: Int? {
        guard let cursorIndex = cursorIndex else { return nil }
        return text.distance(from: text.startIndex, to: cursorIndex)
    }
}
