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
    let countryName: String
    let storeId: String
    let sdmId: Int?
    var timingRef: TimingReference?
    
    func convertToStoreDetail() -> StoreDetail {
        let long = self.longitude
        let lat = self.latitude 
        return StoreDetail(_id: self.storeId, nameArabic: self.restaurantNameArabic, distance: 0, nameEnglish: self.restaurantNameEnglish, sdmId: self.sdmId, restaurantLocation: RestaurantLocation(coordinates: [self.longitude, self.latitude], areaNameEnglish: self.areaNameEnglish, areaNameArabic: self.areaNameArabic, cityName: self.cityName, stateName: self.stateName, countryName: self.countryName))
    }
}

struct TimingReference: Codable {
    let openMins: Int
    let closedMins: Int
    let deliveryRush: Bool
}
