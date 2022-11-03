//
//  MenuListResponse.swift
//  Kudu
//
//  Created by Admin on 25/07/22.
//

import Foundation

struct MenuListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [MenuCategory]?
}

struct MenuCategory: Codable {
    let titleEnglish: String?
    let _id: String?
    let menuImageUrl: String?
    let titleArabic: String?
    let itemCount: Int?
    let items: [MenuItem]?
    let isTimeRangeSet: Bool?
    let timeRange: [TimeRange]?
}

struct TimeRange: Codable {
    let _id: String?
    let day: String?
    let startTime: Int?
    let endTime: Int?
    
    static func filterArrayOfCategories(categories: [MenuCategory]) -> [MenuCategory] {
        let copyArray: [MenuCategory] = categories.filter({
            let timeRanges = $0.timeRange
            var addCategory = false
            if !($0.isTimeRangeSet ?? false) {
                return true
            }
            timeRanges?.forEach({ (timeRange) in
                let day = WeekDay(rawValue: timeRange.day ?? "")
                guard let day = day else { return }
                if day.checkIfToday() {
                    let startTime = timeRange.startTime ?? 0
                    let endTime = timeRange.endTime ?? 0
                    let now = Date().totalMinutes
                    if now >= startTime && now <= endTime {
                        addCategory = true
                        return
                    }
                }
            })
            if addCategory == false {
                debugPrint("CATEGORY REMOVED : \($0.titleEnglish ?? "")")
            }
            return addCategory
        })
        return copyArray
    }
    
    static func checkIfCategoryAllowedTimeWise(category: MenuSearchResultItem) -> Bool {
        let timeRanges = category.timeRange
        var addCategory = false
        if !(category.isTimeRangeSet ?? false) {
            return true
        }
        timeRanges?.forEach({ (timeRange) in
            let day = WeekDay(rawValue: timeRange.day ?? "")
            guard let day = day else { return }
            if day.checkIfToday() {
                let startTime = timeRange.startTime ?? 0
                let endTime = timeRange.endTime ?? 0
                let now = Date().totalMinutes
                if now >= startTime && now <= endTime {
                    addCategory = true
                    return
                }
            }
        })
        if addCategory == false {
            debugPrint("CATEGORY REMOVED : \(category.titleEnglish ?? "")")
        }
        return addCategory
    }
    
    static func filterArrayOfCategories(categories: [MenuSearchResultItem]) -> [MenuSearchResultItem] {
        let copyArray: [MenuSearchResultItem] = categories.filter({
            let timeRanges = $0.timeRange
            var addCategory = false
            if !($0.isTimeRangeSet ?? false) {
                return true
            }
            timeRanges?.forEach({ (timeRange) in
                let day = WeekDay(rawValue: timeRange.day ?? "")
                guard let day = day else { return }
                if day.checkIfToday() {
                    let startTime = timeRange.startTime ?? 0
                    let endTime = timeRange.endTime ?? 0
                    let now = Date().totalMinutes
                    if now >= startTime && now <= endTime {
                        addCategory = true
                        return
                    }
                }
            })
            if addCategory == false {
                debugPrint("CATEGORY REMOVED : \($0.titleEnglish ?? "")")
            }
            return addCategory
        })
        return copyArray
    }
    
    enum WeekDay: String {
        case Everyday
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
        case Sunday
        
        func checkIfToday() -> Bool {
            let today = Date().weekday
            switch self {
            case .Everyday:
                return true
            case .Monday:
                return today == 2
            case .Tuesday:
                return today == 3
            case .Wednesday:
                return today == 4
            case .Thursday:
                return today == 5
            case .Friday:
                return today == 6
            case .Saturday:
                return today == 7
            case .Sunday:
                return today == 1
            }
        }
        
        static func getWeekDay(date: Date = Date()) -> WeekDay {
            let weekday = date.weekday
            switch weekday {
            case 2:
                return .Monday
            case 3:
                return .Tuesday
            case 4:
                return .Wednesday
            case 5:
                return .Thursday
            case 6:
                return .Friday
            case 7:
                return .Saturday
            default:
                return .Sunday
            }
        }
    }
}
