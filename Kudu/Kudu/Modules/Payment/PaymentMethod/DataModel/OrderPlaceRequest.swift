//
//  OrderPlaceRequest.swift
//  Kudu
//
//  Created by Admin on 29/09/22.
//

import Foundation

enum OrderTimeType: String {
    case normal = "1"
    case scheduled = "2"
}

enum PaymentType: String {
    case COD = "2"
}

struct OrderPlaceRequest {
    // STORE KEYS
    let storeId: String
    let storeSdmId: Int
    let restaurantLocation: StoreDetail
    // ORDER KEYS
    let servicesType: APIEndPoints.ServicesType
    let orderType: OrderTimeType
    let paymentType: PaymentType
    let vat: Double
    let totalItemAmount: Double
    let totalAmount: Double
    
    // DELIVERY FLOW KEYS
    let deliveryCharge: Double?
    let userAddress: MyAddressListItem?
    let addressId: String?
    
    // CURBSIDE FLOW KEYS
    let vehicleDetails: VehicleDetails?
    
    // COUPON KEYS
    let isCouponApplied: Bool
    let couponCode: String?
    let couponId: String?
    let discount: Double?
    let offerType: PromoOfferType?
    let promoId: String?
    
    let appVersion: String = "IOS V1"
    
    func getRequest() -> [String: Any] {
        let key = Constants.APIKeys.self
        var params: [String: Any] = [key.storeId.rawValue: storeId,
                                     key.storeSdmId.rawValue: storeSdmId,
                                     key.servicesType.rawValue: servicesType.rawValue,
                                     key.orderType.rawValue: orderType.rawValue,
                                     key.paymentType.rawValue: paymentType.rawValue,
                                     key.vat.rawValue: vat,
                                     key.isCouponApplied.rawValue: isCouponApplied,
                                     key.appVersion.rawValue: appVersion,
                                     key.totalAmount.rawValue: totalAmount,
                                     key.totalItemAmount.rawValue: totalItemAmount]
        let restaurantObject: [String: Any] = [key.coordinates.rawValue: restaurantLocation.restaurantLocation?.coordinates ?? [0, 0],
                                               key.areaNameEnglish.rawValue: restaurantLocation.restaurantLocation?.areaNameEnglish ?? "",
                                               key.areaNameArabic.rawValue: restaurantLocation.restaurantLocation?.areaNameEnglish ?? "",
                                               key.cityName.rawValue: restaurantLocation.restaurantLocation?.cityName ?? "",
                                               key.stateName.rawValue: restaurantLocation.restaurantLocation?.stateName ?? "",
                                               key.countryName.rawValue: restaurantLocation.restaurantLocation?.countryName ?? ""]
        params[key.restaurantLocation.rawValue] = restaurantObject
        if servicesType == .delivery {
            params[key.deliveryCharge.rawValue] = deliveryCharge!
            params[key.addressId.rawValue] = addressId!
            params[key.userAddress.rawValue] = userAddress!.convertToRequest().getRequestJson()
            
        }
        if servicesType == .curbside {
            let vehicleDict: [String: Any] = [key.vehicleNumber.rawValue: vehicleDetails?.vehicleNumber ?? "",
                                              key.vehicleName.rawValue: vehicleDetails?.vehicleName ?? "",
                                              key.colorCode.rawValue: vehicleDetails?.colorCode ?? "",
                                              key.colorName.rawValue: vehicleDetails?.colorName ?? ""]
            params[key.vehicleDetails.rawValue] = vehicleDict
        }
        if isCouponApplied {
            params[key.couponCode.rawValue] = couponCode!
            params[key.discount.rawValue] = discount ?? 0.0
            params[key.couponId.rawValue] = couponId!
            params[key.offerType.rawValue] = offerType?.rawValue ?? ""
            params[key.promoId.rawValue] = promoId
        }
        return params
    }
}
