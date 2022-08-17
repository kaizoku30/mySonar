import Foundation

extension Int {
  func degreesToRads() -> Double {
    return (Double(self) * .pi / 180)
  }
}

extension Int {
    func convertMinutesToAMPM(smallcase: Bool = false) -> String {
        var hourString = ""
        var minuteString = ""
        var hours = self/60
        let minutes = self%60
        minuteString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        var amPm: String = LocalizedStrings.SetRestaurant.amString
        if hours > 11 {
            
            if hours == 24 {
                amPm = LocalizedStrings.SetRestaurant.amString
                hours = 12
                hourString = "\(hours)"
            } else if hours == 12 {
                amPm = LocalizedStrings.SetRestaurant.pmString
                hours = 12
                hourString = "\(hours)"
            } else {
                amPm = LocalizedStrings.SetRestaurant.pmString
                hours -= 12
                hourString = "\(hours)"
            }
        } else {
            hourString = hours < 10 ? "0\(hours)" : "\(hours)"
        }
        let output = hourString + CommonStrings.colon + minuteString + CommonStrings.whiteSpace + amPm
        debugPrint("Incoming minutestamp : \(self)")
        debugPrint("Output : \(output)")
        return !smallcase ? output : output.replace(string: "AM", withString: "am").replace(string: "PM", withString: "pm")
    }
}
