//
//  SelectedStoresResponseModel.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import Foundation

struct SelectedStoresResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: StoreMinDetailsData?
}

struct StoreMinDetailsData: Codable {
    let data: [StoreMinDetail]?
    let total: Int?
    let pageNo: Int?
}

struct StoreMinDetail: Codable {
    let _id: String?
    let nameEnglish: String?
    let nameArabic: String?
    let restaurantLocation: RestaurantLocation?
}
