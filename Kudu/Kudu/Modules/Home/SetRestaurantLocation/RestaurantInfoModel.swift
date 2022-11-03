//
//  RestaurantInfoModel.swift
//  Kudu
//
//  Created by Admin on 27/07/22.
//

import Foundation

struct RestaurantInfoModel: Codable {
    let restaurantNameEnglish: String
    let restaurantNameArabic: String
    let areaNameEnglish: String
    let areaNameArabic: String
    let latitude: Double
    let longitude: Double
    let cityName: String
    let stateName: String
    let zipCode: String
    let countryName: String
    let storeId: String
    let sdmId: Int?
    let workingHoursStartTimeInMinutes: Int?
    let workingHoursEndTimeInMinutes: Int?
    let deliveryTimingFromInMinutes: Int?
    let deliveryTimingToInMinutes: Int?
    let curbSideTimingFromInMinutes: Int?
    let curbSideTimingToInMinutes: Int?
    let pickupTimingFromInMinutes: Int?
    let pickupTimingToInMinutes: Int?
    let serviceCurbSide: Bool?
    let serviceDelivery: Bool?
    let servicePickup: Bool?
    let isRushHour: Bool?
    let workingDay: [String]?
    let minimumOrderValue: Int?
    let restaurantStatus: String?
    let paymentMethod: [String]?
    
    func convertToStoreDetail() -> StoreDetail {
        return StoreDetail(_id: self.storeId, nameArabic: self.restaurantNameArabic, distance: 0, nameEnglish: self.restaurantNameEnglish, sdmId: self.sdmId ?? 0, restaurantLocation: RestaurantLocation(coordinates: [self.longitude, self.latitude], areaNameEnglish: self.areaNameEnglish, areaNameArabic: self.areaNameArabic, cityName: self.cityName, stateName: self.stateName, countryName: self.countryName, zipCode: self.zipCode), workingHoursStartTimeInMinutes: self.workingHoursStartTimeInMinutes ?? 0, workingHoursEndTimeInMinutes: self.workingHoursEndTimeInMinutes ?? 0, deliveryTimingFromInMinutes: self.deliveryTimingFromInMinutes ?? 0, deliveryTimingToInMinutes: self.deliveryTimingToInMinutes ?? 0, curbSideTimingFromInMinutes: self.curbSideTimingFromInMinutes ?? 0, curbSideTimingToInMinutes: self.curbSideTimingToInMinutes ?? 0, pickupTimingFromInMinutes: self.pickupTimingFromInMinutes ?? 0, pickupTimingToInMinutes: self.pickupTimingToInMinutes ?? 0, serviceCurbSide: self.serviceCurbSide ?? false, serviceDelivery: self.serviceDelivery ?? false, servicePickup: self.servicePickup ?? false, isRushHour: self.isRushHour ?? false, workingDay: self.workingDay ?? [], minimumOrderValue: self.minimumOrderValue ?? 0, restaurantStatus: self.restaurantStatus, paymentMethod: self.paymentMethod ?? [])
    }
}
