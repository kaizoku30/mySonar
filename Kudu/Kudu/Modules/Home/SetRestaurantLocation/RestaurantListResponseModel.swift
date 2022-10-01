//
//  RestaurantListResponseModel.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import Foundation

struct RestaurantListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: RestaurantListData?
}

struct RestaurantListData: Codable {
    let list: [RestaurantListItem]?
    let totalRecord: Int?
}

struct RestaurantListItem: Codable {
    let _id: String?
    let servicePickup: Bool?
    let serviceCurbSide: Bool?
    let serviceDelivery: Bool?
    let restaurantLocation: RestaurantLocation?
    let nameEnglish: String?
    let nameArabic: String?
    let storeNote: String?
    let storeNoteEnglish: String?
    let workingHoursStartTime: String?
    let workingHoursEndTime: String?
    let distance: Double?
    let pickupTimingFrom: String?
    let pickupTimingTo: String?
    let curbSideTimingFrom: String?
    let curbSideTimingTo: String?
    let curbSideTimingFromInMinutes: Int?
    let curbSideTimingToInMinutes: Int?
    let deliveryTimingFromInMinutes: Int?
    let deliveryTimingToInMinutes: Int?
    let pickupTimingFromInMinutes: Int?
    let pickupTimingToInMinutes: Int?
    let workingHoursEndTimeInMinutes: Int?
    let workingHoursStartTimeInMinutes: Int?
    let isRushHour: Bool?
    let sdmId: Int?
    
}

struct RestaurantLocation: Codable {
    let coordinates: [Double]?
    //Long at 0, Lat 1
    let areaNameEnglish: String?
    let areaNameArabic: String?
    let cityName: String?
    let stateName: String?
    let countryName: String?
}
