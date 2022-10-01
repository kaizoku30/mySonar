import Foundation

extension Date {
    
    struct ComponentsDate {
        let seconds: Int
        let minutes: Int
        let hours: Int
        let days: Int
        let weeks: Int
        let months: Int
        let years: Int
    }

    // MARK: - DATE FORMAT ENUM
    enum DateFormat: String {

        case yyyy_MM_dd = "yyyy-MM-dd"
        case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
        case yyyyMMddTHHmmssz = "yyyy-MM-dd'T'HH:mm:ssZ"
        case yyyyMMddHHmmssz = "yyyy-MM-ddHH:mm:ssZ"
        case yyyyMMddTHHmmssssZZZZZ = "yyyy-MM-dd'T'HH:mm:ss.ssZZZZZ"
        case yyyyMMddTHHmmsssssZ = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        case yyyyMMdd = "yyyy/MM/dd"
        case ddMMyy = "dd/MM/yy"
        case dMMMyyyy = "d MMM, yyyy"
        case dMMMyyyyWithNewLine = "d\nMMM yyyy"
        case ddMMMyyyy = "dd MMM yyyy"
        case ddMMM = "dd MMM"
        case MMMdd = "MMM dd"
        case MMMYYYY = "MMM yyyy"
        case MMMdyyyy = "MMM d, yyyy"
        case HHmm = "HH:mm"
        case hmmazzz = "h:mm a"
        case MMMdyyyyHHmmss = "MMM d, yyyy HH:mm:ss"
        case dMMMEEEHHmmss = "d MMM, EEEE h:mm a"
        case dMMMEEHHmmss = "d MMM, EEE h:mm a"
        case dMMMYYYYEEHHmmss = "d MMM YYYY, EEE h:mm a"
        case MMMdyyyyHHmma = "MMM d, yyyy h:mm a"
        case ddd = "ddd"
        case dd = "dd"
        case mm = "MM"
        case yyyy = "YYYY"
        case EEEE = "EEEE"
        case EEE = "EEE"
        case MMM = "MMM"
        case yy = "yy"
    }

    static let todaysDate = Date()
    static let dateFormatter = DateFormatter()

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    var isWeekend: Bool {
        return Calendar.current.isDateInWeekend(self)
    }
    var year: Int {
        return (Calendar.current as NSCalendar).components(.year, from: self).year!
    }
    var month: Int {
        return (Calendar.current as NSCalendar).components(.month, from: self).month!
    }
    var weekOfYear: Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: self).weekOfYear!
    }
    var weekday: Int {
        return (Calendar.current as NSCalendar).components(.weekday, from: self).weekday!
    }
    var weekdayOrdinal: Int {
        return (Calendar.current as NSCalendar).components(.weekdayOrdinal, from: self).weekdayOrdinal!
    }
    var weekOfMonth: Int {
        return (Calendar.current as NSCalendar).components(.weekOfMonth, from: self).weekOfMonth!
    }
    var day: Int {
        return (Calendar.current as NSCalendar).components(.day, from: self).day!
    }
    var hour: Int {
        return (Calendar.current as NSCalendar).components(.hour, from: self).hour!
    }
    var minute: Int {
        return (Calendar.current as NSCalendar).components(.minute, from: self).minute!
    }
    var second: Int {
        return (Calendar.current as NSCalendar).components(.second, from: self).second!
    }
    var numberOfWeeks: Int {
        let weekRange = (Calendar.current as NSCalendar).range(of: .weekOfYear, in: .month, for: Date())
        return weekRange.length
    }
    var unixTimestamp: Double {

        return self.timeIntervalSince1970
    }

    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func weekdayFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekday, from: date, to: self, options: []).weekday!
    }
    func weekdayOrdinalFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekdayOrdinal, from: date, to: self, options: []).weekdayOrdinal!
    }
    func weekOfMonthFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfMonth, from: date, to: self, options: []).weekOfMonth!
    }
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 {
            return "\(yearsFrom(date))y"}
        if monthsFrom(date)  > 0 {
            return "\(monthsFrom(date))M"}
        if weeksFrom(date)   > 0 {
            return "\(weeksFrom(date))w"}
        if daysFrom(date)    > 0 {
            return "\(daysFrom(date))d"}
        if hoursFrom(date)   > 0 {
            return "\(hoursFrom(date))h"}
        if minutesFrom(date) > 0 {
            return "\(minutesFrom(date))m"}
        if secondsFrom(date) > 0 {
            return "\(secondsFrom(date))s"}
        return CommonStrings.emptyString
    }
    
    func isSameDate() -> Bool {
        let todayDate = Date()
        return self.day == todayDate.day && self.year == todayDate.year && self.month == todayDate.month
    }
    
    func isLessDateOrEqualWithTime(_ date: Date) -> Bool {
        let sameData = self.day == date.day && self.year == date.year && self.month == date.month
        if sameData {
            return self.hour <= date.hour
        } else {
            return self.isLessThan(date)
        }
    }
    
    var totalMinutes: Int {
        return self.hour*60 + self.minute
    }

    func isGreaterDateEqualWithTime(_ date: Date) -> Bool {
        let sameData = self.day == date.day && self.year == date.year && self.month == date.month
        if sameData {
            return self.hour >= date.hour
        } else {
            return self.isGreaterThan(date)
        }
    }
    
    /// Converts a given Date into String based on the date format and timezone provided
    func isDayEqualTo(dayName: String, timeZone: TimeZone = TimeZone.current) -> Bool {
        let frmtr = DateFormatter()
        frmtr.dateFormat = DateFormat.EEE.rawValue
        frmtr.timeZone = timeZone
        return frmtr.string(from: self) == dayName
    }
    
    /// Converts a given Date into String based on the date format and timezone provided
    func toString(dateFormat: String, timeZone: TimeZone = TimeZone.current) -> String {
        let frmtr = DateFormatter()
        frmtr.dateFormat = dateFormat
        frmtr.timeZone = timeZone
        return frmtr.string(from: self)
    }
    
    func calculateAge() -> Int {

        let calendar: Calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day]
        let dateComponentNow: DateComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        let dateComponentBirth: DateComponents = (calendar as NSCalendar).components(unitFlags, from: self)

        if (dateComponentNow.month! < dateComponentBirth.month!) ||
            ((dateComponentNow.month! == dateComponentBirth.month!) && (dateComponentNow.day! < dateComponentBirth.day!)) {
            return dateComponentNow.year! - dateComponentBirth.year! - 1
        } else {
            return dateComponentNow.year! - dateComponentBirth.year!
        }
    }

    static func zero() -> Date {
        let dateComp = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, era: 0, year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0, nanosecond: 0, weekday: 0, weekdayOrdinal: 0, quarter: 0, weekOfMonth: 0, weekOfYear: 0, yearForWeekOfYear: 0)
        return dateComp.date!
    }

    func convertToString(dateFormat: String = "MM/dd/yyyy") -> String {
        let formatterForString = DateFormatter()
        formatterForString.dateFormat = dateFormat
        let local = formatterForString.string(from: self)
        return local
    }
    
    func serverDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone.current
        return (formatter.string(from: self))
    }
}

public extension Date {
    
    func minus(date d: Date) -> DateComponents {
        let component = ComponentsDate(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0)
        return Calendar.current.dateComponents([.month, .weekOfMonth, .day], from: self, to: self.addComponentsToDate(component))
    }
    
    func noOfDaysFrom(date d: Date) -> Int {
        let component = ComponentsDate(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0)
        return Calendar.current.dateComponents([.day], from: d, to: self.addComponentsToDate(component)).day ?? 0
    }

    fileprivate func addComponentsToDate(_ components: ComponentsDate) -> Date {
        var dc = DateComponents()
        dc.second = components.seconds
        dc.minute = components.minutes
        dc.hour = components.hours
        dc.day = components.days
        dc.weekOfYear = components.weeks
        dc.month = components.months
        dc.year = components.years
        return Calendar.current.date(byAdding: dc, to: self)!
    }

    func midnightUTCDate() -> Date {
        var dc: DateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        dc.timeZone = TimeZone(secondsFromGMT: 0)
        return Calendar.current.date(from: dc)!
    }

    static func secondsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.second], from: d1, to: d2)
        return dc.second!
    }

    static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.minute], from: d1, to: d2)
        return dc.minute!
    }

    static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.hour], from: d1, to: d2)
        return dc.hour!
    }

    static func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.day], from: d1, to: d2)
        return dc.day!
    }

    static func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.weekOfYear], from: d1, to: d2)
        return dc.weekOfYear!
    }

    static func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.month], from: d1, to: d2)
        return dc.month!
    }

    static func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents([.year], from: d1, to: d2)
        return dc.year!
    }

    // MARK: Comparison Methods

    func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }

    func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }

    func yearOfDate() -> String? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
        // or use capitalized(with: locale) if you want

    }
    
    func monthAndYearOfDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.MMMYYYY.rawValue
        return dateFormatter.string(from: self)
    }

    func monthOfDate() -> String {
        let monthValue = Calendar.current.component(.month, from: self)
        return monthValue > 9 ? "\(monthValue)": "0\(monthValue)"
    }
    
    func checkValidDod() -> Bool {
        if self.calculateAge() >= 21 && self.calculateAge() < 115 {
            return true
        } else {
            return false
        }
    }
}

extension Date {

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func removeTimeStamp() -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
        guard let date = calendar.date(from: calendar.dateComponents([.year, .month, .day], from: self)) else {
            return self
        }
        return date
    }
    
    func removeTimeStampByCreateDate() -> Date {
        return Self.createDate(month: self.month, day: self.day, year: self.year) ?? self
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let date = self.removeTimeStamp()
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: date))
        return Date(timeInterval: seconds, since: date)
    }
    
    // Convert UTC (or GMT) to local time
    func toNewLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    func localDate() -> Date {
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: self))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: self) else {return self}
        return localDate
    }
    
    func localDateWithoutTimeStamp() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        let calendar = Calendar.current
        guard let localDate = calendar.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: localDate)
        return calendar.date(from: dateComponents) ?? localDate
    }

}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var millisecondsSince1970: Double {
        return (self.timeIntervalSince1970 * 1000.0).rounded()
    }
    
    static func createDate(month: Int, day: Int, year: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, timeZone: String = "UTC") -> Date? {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone.init(abbreviation: timeZone)
        return Calendar.current.date(from: components)
    }
    
    static func createTime(hour: Int, minute: Int, second: Int) -> Date? {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)
    }
    
    func dateTimeStampWithoutTime() -> Double {
        let date = Date.createDate(month: self.month, day: self.day, year: self.year)
        return date?.timeIntervalSince1970 ?? 0
    }
    
    static func getTotalDaysInAYear(year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        let calendar = Calendar.current
        guard let datez = calendar.date(from: dateComponents) else { return 0 }
        guard let interval = calendar.dateInterval(of: .year, for: datez) else { return 0 }
        guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return 0 }
        return days
    }
    
    func getTotalDaysInCurrentYear() -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = self.toNewLocalTime().year
        let calendar = Calendar.current
        guard let datez = calendar.date(from: dateComponents) else { return 0 }
        guard let interval = calendar.dateInterval(of: .year, for: datez) else { return 0 }
        guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return 0 }
        return days
    }
    
    static func getTotalDays(month: Int, year: Int) -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        let calendar = Calendar.current
        guard let datez = calendar.date(from: dateComponents) else { return 0 }
        guard let interval = calendar.dateInterval(of: .month, for: datez) else { return 0 }
        guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return 0 }
        return days
    }
    
    func getTotalDaysInCurrentMonth() -> Int {
        var dateComponents = DateComponents()
        dateComponents.year = self.toNewLocalTime().year
        dateComponents.month = self.toNewLocalTime().month
        let calendar = Calendar.current
        guard let datez = calendar.date(from: dateComponents) else { return 0 }
        guard let interval = calendar.dateInterval(of: .month, for: datez) else { return 0 }
        guard let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day else { return 0 }
        return days
    }

}

extension TimeZone {

    func offsetFromUTC() -> String {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }

    func offsetInHours() -> String {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

extension String {
    /// Converts the string into 'Date' if possible, based on the given date format and timezone. otherwise returns nil
    func toDate(dateFormat: String, timeZone: TimeZone = TimeZone.current) -> Date? {
        
        let frmtr = DateFormatter()
        //frmtr.locale = Locale(identifier: "en_US_POSIX")
        frmtr.timeZone = timeZone
        frmtr.dateFormat = dateFormat
        return frmtr.date(from: self)
    }
    
    func getTotalNoOfDaysLeft(dateFormat: String, endDate: Date = Date()) -> Int {
        if let startDate = self.toDate(dateFormat: dateFormat) {
           return startDate.noOfDaysFrom(date: endDate)
        }
        return 0
    }
    
    func stringToStrDate(inputFormate: String = "yyyy-MM-dd", outputFormat: String = "dd MMM yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormate
        guard let date = formatter.date(from: self) else { return ""}
        formatter.dateFormat =  outputFormat
        return formatter.string(from: date)
    }
}
