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
    let workingDay: [String]?
    let minimumOrderValue: Int?
    let restaurantStatus: String?
    let paymentMethod: [String]?
    
    func convertToRestaurantInfo() -> RestaurantInfoModel {
        let item = self
        return RestaurantInfoModel(restaurantNameEnglish: item.nameEnglish ?? "", restaurantNameArabic: item.nameArabic ?? "", areaNameEnglish: item.restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: item.restaurantLocation?.areaNameArabic ?? "", latitude: item.restaurantLocation?.coordinates?.last ?? 0, longitude: item.restaurantLocation?.coordinates?.first ?? 0, cityName: item.restaurantLocation?.cityName ?? "", stateName: item.restaurantLocation?.stateName ?? "", zipCode: item.restaurantLocation?.zipCode ?? "", countryName: item.restaurantLocation?.countryName ?? "", storeId: item._id ?? "", sdmId: item.sdmId ?? 0, workingHoursStartTimeInMinutes: item.workingHoursStartTimeInMinutes ?? 0, workingHoursEndTimeInMinutes: item.workingHoursEndTimeInMinutes ?? 0, deliveryTimingFromInMinutes: item.deliveryTimingFromInMinutes ?? 0, deliveryTimingToInMinutes: item.deliveryTimingToInMinutes ?? 0, curbSideTimingFromInMinutes: item.deliveryTimingFromInMinutes ?? 0, curbSideTimingToInMinutes: item.curbSideTimingToInMinutes, pickupTimingFromInMinutes: item.pickupTimingFromInMinutes ?? 0, pickupTimingToInMinutes: item.pickupTimingToInMinutes ?? 0, serviceCurbSide: item.serviceCurbSide ?? false, serviceDelivery: item.serviceDelivery ?? false, servicePickup: item.servicePickup ?? false, isRushHour: item.isRushHour ?? false, workingDay: item.workingDay ?? [], minimumOrderValue: item.minimumOrderValue ?? 0, restaurantStatus: restaurantStatus, paymentMethod: self.paymentMethod ?? [])
    }
}

struct RestaurantLocation: Codable {
    let coordinates: [Double]?
    //Long at 0, Lat 1
    let areaNameEnglish: String?
    let areaNameArabic: String?
    let cityName: String?
    let stateName: String?
    let countryName: String?
    let zipCode: String?
}
