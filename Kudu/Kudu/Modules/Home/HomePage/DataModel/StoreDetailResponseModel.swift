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
    
    func convertToRestaurantInfo() -> RestaurantInfoModel {
        RestaurantInfoModel(restaurantNameEnglish: self.nameEnglish ?? "", restaurantNameArabic: self.nameArabic ?? "", areaNameEnglish: self.restaurantLocation?.areaNameEnglish ?? "", areaNameArabic: self.restaurantLocation?.areaNameArabic ?? "", latitude: self.restaurantLocation?.coordinates?.last ?? 0.0, longitude: self.restaurantLocation?.coordinates?.first ?? 0.0, cityName: self.restaurantLocation?.cityName ?? "", stateName: self.restaurantLocation?.stateName ?? "", countryName: self.restaurantLocation?.countryName ?? "", storeId: self._id ?? "", sdmId: self.sdmId ?? 0)
    }
}
