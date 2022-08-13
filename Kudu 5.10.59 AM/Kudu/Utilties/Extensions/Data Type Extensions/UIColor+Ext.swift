import Foundation
import UIKit

// UIColor Extension
extension UIColor {
    
    /// Method to initialize the color with r g b and alpha value
    /// - Parameters:
    ///   - r: Int value for red color
    ///   - g: Int value for green color
    ///   - b: Int value for blue color
    ///   - alpha: CGFloat value for alpha
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat) {
        assert(r >= 0 && r <= 255, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        assert(alpha >= 0 && alpha <= 1, "Invalid alpha component")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    /// Returns the color based on the given R,G,B and alpha values
    class func colorRGB(r: Int, g: Int, b: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(r: r, g: g, b: b, alpha: alpha)
    }
    
    /// Variable to get random color
    static var random: UIColor {
        return UIColor(red: .random(in: 0...0.6),
                       green: .random(in: 0...0.6),
                       blue: .random(in: 0...0.6),
                       alpha: 1.0)
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
