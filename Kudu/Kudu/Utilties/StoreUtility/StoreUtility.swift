//
//  StoreUtility.swift
//  Kudu
//
//  Created by Admin on 03/10/22.
//

import Foundation

final class StoreUtility {
    static func checkIfAnyStoreNearby(lat: Double, long: Double, checked: @escaping (Result<StoreDetail, Error>) -> Void) {
        APIEndPoints.HomeEndPoints.getStoreDetailsForDelivery(lat: lat, long: long, servicesType: .delivery, success: {
            guard let store = $0.data else {
                checked(.failure(NSError(localizedDescription: "Could not find any store nearby")))
                return }
            checked(.success(store))
        }, failure: {
            checked(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    private static func checkWeekdayOpen(_ weekdays: [String]) -> Bool {
        var openToday = false
        weekdays.forEach({
            let weekday = TimeRange.WeekDay(rawValue: $0)
            if let weekday = weekday, weekday.checkIfToday() {
                openToday = true
            }
        })
        return openToday
    }
    
    static func checkStoreOpen(_ restaurant: RestaurantListItem, serviceType: APIEndPoints.ServicesType) -> Bool {
        
        if restaurant.restaurantStatus ?? "" != "active" {
            return false
        }
        
        if !checkWeekdayOpen(restaurant.workingDay ?? []) {
            return false
        }
        
        var storeTimeOpen = restaurant.workingHoursStartTimeInMinutes ?? 0
        var storeTimeClose = restaurant.workingHoursEndTimeInMinutes ?? 0
        let currentTime = Date().totalMinutes
        if currentTime < storeTimeOpen || currentTime > storeTimeClose {
            return false
        }
        
        switch serviceType {
        case .curbside:
            storeTimeOpen = restaurant.curbSideTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.curbSideTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        case .delivery:
            storeTimeOpen = restaurant.deliveryTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.deliveryTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        case .pickup:
            storeTimeOpen = restaurant.pickupTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.pickupTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        }
        return true
    }
    
    static func checkIfScheduleDateApplicable(date: TimeInterval, store: StoreDetail, service: APIEndPoints.ServicesType) -> Bool {
        let dateObj = Date(timeIntervalSince1970: date)
        let weekDayType = TimeRange.WeekDay.getWeekDay(date: dateObj)
        let arrayOfWeekdays = store.workingDay ?? []
        if !arrayOfWeekdays.contains(where: { $0 == weekDayType.rawValue }) {
            return false
        }
        let time = dateObj.totalMinutes
        var storeTimeOpen = store.workingHoursStartTimeInMinutes ?? 0
        var storeTimeClose = store.workingHoursEndTimeInMinutes ?? 0
        if time < storeTimeOpen || time > storeTimeClose {
            return false
        }
        switch service {
        case .curbside:
            storeTimeOpen = store.curbSideTimingFromInMinutes ?? 0
            storeTimeClose = store.curbSideTimingToInMinutes ?? 0
        case .delivery:
            storeTimeOpen = store.deliveryTimingFromInMinutes ?? 0
            storeTimeClose = store.deliveryTimingToInMinutes ?? 0
        case .pickup:
            storeTimeOpen = store.pickupTimingFromInMinutes ?? 0
            storeTimeClose = store.pickupTimingToInMinutes ?? 0
        }
        if time < storeTimeOpen || time > storeTimeClose {
            return false
        }
        return true
    }
    
    static func checkStoreOpen(_ restaurant: StoreDetail, serviceType: APIEndPoints.ServicesType) -> Bool {
        
        if restaurant.restaurantStatus ?? "" != "active" {
            return false
        }
        
        if !checkWeekdayOpen(restaurant.workingDay ?? []) {
            return false
        }
        
        var storeTimeOpen = restaurant.workingHoursStartTimeInMinutes ?? 0
        var storeTimeClose = restaurant.workingHoursEndTimeInMinutes ?? 0
        let currentTime = Date().totalMinutes
        if currentTime < storeTimeOpen || currentTime > storeTimeClose {
            return false
        }
        
        switch serviceType {
        case .curbside:
            storeTimeOpen = restaurant.curbSideTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.curbSideTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        case .delivery:
            storeTimeOpen = restaurant.deliveryTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.deliveryTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        case .pickup:
            storeTimeOpen = restaurant.pickupTimingFromInMinutes ?? 0
            storeTimeClose = restaurant.pickupTimingToInMinutes ?? 0
            if currentTime < storeTimeOpen || currentTime > storeTimeClose {
                return false
            }
        }
        return true
    }
}
