import Foundation
import UIKit

 extension NSObject {

    /// Retruns the name of the class
    class var className: String {
        return NSStringFromClass(self).components(separatedBy: CommonStrings.dot).last!
    }
    /// Retruns the name of the class
    var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: CommonStrings.dot).last!
    }
}
