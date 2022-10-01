//
//  CouponListingResponseModel.swift
//  Kudu
//
//  Created by Admin on 25/09/22.
//

import Foundation

enum DeliveryDiscountType: String {
    case fixedDiscount = "1"
    case discountPercentage = "2"
}

enum PromoOfferType: String {
    case discount = "1"
    case item = "2"
    case freeDelivery = "3"
    case discountedDelivery = "4"
    
    var typeName: String {
        switch self {
        case .discount:
            return "Discount"
        case .item:
            return "Item"
        case .freeDelivery:
            return "Free Delivery"
        case .discountedDelivery:
            return "Discounted Delivery"
        }
    }
}

struct CouponListingResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: [CouponObject]?
}

struct CouponDetailResponse: Codable {
    let message: String?
    let statusCode: Int?
    let data: [CouponObject]?
}

struct CouponCodeBasedDetailResponse: Codable {
    let message: String?
    let statusCode: Int?
    let data: CouponCodeBasedData?
}

struct CouponCodeBasedData: Codable {
    let isApplicable: Bool?
    let data: CouponObject?
}

struct CouponObject: Codable {
    let _id: String?
    let imageArabic: String?
    let imageEnglish: String?
    var promoData: PromoData?
    let couponCode: [CouponCodeData]?
    let excludeLocations: [String]?
    let nameEnglish: String?
    let nameArabic: String?
    let descriptions: [CouponDescriptionPointer]?
    let validTo: Int?
    let validFrom: Int?
    let validToTime: Int?
    let validFromTime: Int?
}

struct PromoData: Codable {
    let _id: String?
    let status: String?
    let menuTemplateId: String?
    let servicesAvailable: String?
    let items: [String]?
    let discountType: String?
    let discountInPercentage: Int?
    let maximumDiscount: Int?
    let minimumCartAmount: Int?
    let discountedAmount: Int?
    let twenty4By7: Bool?
    let offerType: String?
    let cartMustCategories: [String]?
    let cartMustItems: [String]?
    let promotionName: String?
    let promotionType: String?
    let specialDeliveryPrice: Int?
    let navigationTo: [NavigationInfo]?
    let eachDayTime: [PromoWeeklyTimeInfo]?
}

struct PromoWeeklyTimeInfo: Codable {
    let dayName: String?
    let validFromTime: Int?
    let validToTime: Int?
}

struct NavigationInfo: Codable {
    let id: String?
    let _id: String?
    let nameEnglish: String?
    let nameArabic: String?
    let isCategory: Bool?
    let isItem: Bool?
    let menuId: String?
}

struct CouponCodeData: Codable {
    let status: String?
    let _id: String?
    let couponCode: String?
}

struct CouponDescriptionPointer: Codable {
    let _id: String?
    let content: String?
}
