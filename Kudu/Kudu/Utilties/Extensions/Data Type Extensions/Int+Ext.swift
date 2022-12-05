import Foundation

extension Int {
  func degreesToRads() -> Double {
    return (Double(self) * .pi / 180)
  }
}

extension Int {
    
    func convertMinutesToAMPM(smallcase: Bool = false, safelyRemovingArabic: Bool = false) -> String {
        var hourString = ""
        var minuteString = ""
        var hours = self/60
        let minutes = self%60
        minuteString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        var amPm: String = !safelyRemovingArabic ?  LSCollection.SetRestaurant.amString : "AM"
        if hours > 11 {
            
            if hours == 24 {
                amPm = !safelyRemovingArabic ?  LSCollection.SetRestaurant.amString : "AM"
                hours = 12
                hourString = "\(hours)"
            } else if hours == 12 {
                amPm = !safelyRemovingArabic ?  LSCollection.SetRestaurant.pmString : "PM"
                hours = 12
                hourString = "\(hours)"
            } else {
                amPm = !safelyRemovingArabic ?  LSCollection.SetRestaurant.pmString : "PM"
                hours -= 12
                hourString = "\(hours)"
            }
        } else {
            hourString = hours < 10 ? "0\(hours)" : "\(hours)"
        }
        let output = hourString + CommonStrings.colon + minuteString + CommonStrings.whiteSpace + amPm
        return !smallcase ? output : output.replace(string: "AM", withString: "am").replace(string: "PM", withString: "pm")
    }
}
