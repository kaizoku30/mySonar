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
    let storeId: String
}
