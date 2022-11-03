//
//  RTCalendarViewModel.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

struct RTCalendarViewModel {
    static let calendar = Calendar.current
    static let date = Date().description(with: Locale.current)

    static func firstDayOfMonth(month: Int, year: Int) -> Date {

        var firstOfMonthComponents = DateComponents()
        firstOfMonthComponents.calendar = calendar
        firstOfMonthComponents.year = year
        firstOfMonthComponents.month = month
        firstOfMonthComponents.day = 01
        
        return firstOfMonthComponents.date!
    }

    static func firstMonday(month: Int, year: Int) -> Date {
        
        let first = firstDayOfMonth(month: month, year: year)

        let dayNumber = calendar.component(.weekday, from: first)
        let daysToAdd = ((calendar.firstWeekday + 7) - dayNumber) % 7
        return calendar.date(byAdding: .day, value: daysToAdd, to: first)!

    }
}
