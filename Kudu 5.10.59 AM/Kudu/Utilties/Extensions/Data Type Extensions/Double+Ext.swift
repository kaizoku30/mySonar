import Foundation

extension Double {
    
    func roundToOneDigitCrore() -> String {
        return String(format: "%.1f", self/10000000)
    }
    
    func roundToOneDigitLac() -> String {
        return String(format: "%.1f", self/100000)
    }
    
    var stringWithoutZeroFraction: String {
        let value = roundToNearest(toNearest: 0.1)
        return value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
    
    var roundToOneDigitCroreValue: Double {
        return Double(String(format: "%.1f", roundDown(self/10000000, toNearest: 0.1))) ?? 0
    }
    
    var roundToOneDigitLacValue: Double {
        return Double(String(format: "%.1f", self/100000)) ?? 0
    }
    
    func roundToNearest(toNearest: Double) -> Double {
        return floor(self / toNearest) * toNearest
        
    }
    // Given a value to round and a factor to round to,
    // round the value DOWN to the largest previous multiple
    // of that factor.
    func roundDown(_ value: Double, toNearest: Double) -> Double {
        return floor(value / toNearest) * toNearest
    }
    
    func truncate(places: Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
    
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func zeroFormat() -> String {
        return String(format: "%.2f", self)
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func checkDecimalZeroAndGiveFormat() -> String {
        let intDouble = Double(Int(self))
        if (self - intDouble).isZero {
            return Int(self).description
        }
        return self.zeroFormat()
    }
    
    func priceLocaleFormat() -> String {
        return self.zeroFormat()
    }
    
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return String(formatter.string(from: number) ?? "")
    }
    
    func oneDigitString() -> String {
        return String(format: "%.1f", self)
    }
    
}

extension Float {
    
    func checkDecimalZeroAndGiveFormat() -> String {
        let intFloat = Float(Int(self))
        if (self - intFloat).isZero {
            return Int(self).description
        }
        return String(format: "%.2f", self)
    }
    
    func zeroFormat() -> String {
        return String(format: "%.2f", self)
    }
    
    func priceLocaleFormat() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: self as NSNumber) ?? self.zeroFormat()
    }
}
