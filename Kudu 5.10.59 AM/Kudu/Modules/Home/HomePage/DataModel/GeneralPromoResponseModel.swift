//
//  GeneralPromoResponse.swift
//  Kudu
//
//  Created by Admin on 24/07/22.
//

import Foundation

struct GeneralPromoResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [GeneralPromoItem]?
}

struct GeneralPromoItem: Codable {
    let _id: String?
    let discountType: String?
    let discountValue: Double?
    let bannerUrl: String?
    var description: String?
    var name: String?
    var couponId: String?
}
