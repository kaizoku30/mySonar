//
//  StoreDetailResponseModel.swift
//  Kudu
//
//  Created by Admin on 08/09/22.
//

import Foundation

struct StoreDetailResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: StoreDetail?
}

struct StoreDetail: Codable {
    let _id: String?
    let nameArabic: String?
    let distance: Double?
    let nameEnglish: String?
    let sdmId: Int?
    let restaurantLocation: RestaurantLocation?
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
    
    func convertToRestaurantInfo() -> RestaurantInfoModel {
        RestaurantInfoModel(restaurantNameEnglish: nameEnglish ?? "", restaurantNameArabic: nameArabic ?? "", areaNameEnglish: restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: restaurantLocation?.areaNameArabic ?? "", latitude: self.restaurantLocation?.coordinates?.last ?? 0.0, longitude: self.restaurantLocation?.coordinates?.first ?? 0.0, cityName: restaurantLocation?.cityName ?? "", stateName: restaurantLocation?.stateName ?? "", zipCode: restaurantLocation?.zipCode ?? "", countryName: restaurantLocation?.countryName ?? "", storeId: self._id ?? "", sdmId: self.sdmId ?? 0, workingHoursStartTimeInMinutes: workingHoursStartTimeInMinutes ?? 0, workingHoursEndTimeInMinutes: workingHoursEndTimeInMinutes ?? 0, deliveryTimingFromInMinutes: deliveryTimingFromInMinutes ?? 0, deliveryTimingToInMinutes: deliveryTimingToInMinutes ?? 0, curbSideTimingFromInMinutes: curbSideTimingFromInMinutes ?? 0, curbSideTimingToInMinutes: curbSideTimingToInMinutes ?? 0, pickupTimingFromInMinutes: pickupTimingFromInMinutes ?? 0, pickupTimingToInMinutes: pickupTimingToInMinutes ?? 0, serviceCurbSide: serviceCurbSide
                            ?? false, serviceDelivery: serviceDelivery ?? false, servicePickup: servicePickup ?? false, isRushHour: isRushHour ?? false, workingDay: workingDay ?? [], minimumOrderValue: minimumOrderValue ?? 0, restaurantStatus: restaurantStatus, paymentMethod: self.paymentMethod ?? [])
    }
}
