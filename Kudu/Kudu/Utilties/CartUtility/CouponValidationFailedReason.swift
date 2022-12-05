//
//  CouponValidationFailedReason.swift
//  Kudu
//
//  Created by Admin on 09/11/22.
//

import Foundation

enum CouponValidationFailedReason: Equatable {
    case timeBounds
    case serviceTypeMismatch(correctOrderType: APIEndPoints.ServicesType)
    case amountNotEnough(amountReq: Int)
    case menuIDsNeeded
    case itemIDsNeeded
   // case cartEmpty
    case storeIdConflict(delivery: Bool)
    
    var errorMsg: String {
        switch self {
        case .timeBounds:
            return "Offer is not applicable for now"
            //return "Offer only valid from \(validFromTime) to \(validToTime)"
        case .serviceTypeMismatch(let correctOrderType):
            var string = "Delivery"
            switch correctOrderType {
            case .curbside:
                string = "Curbside"
            case .delivery:
                break
            case .pickup:
                string = "PickUp"
            }
            return "Offer only valid for \(string) Order Type"
        case .amountNotEnough(let minAmount):
            return "Minimum Cart amount should be SR \(minAmount)"
        case .menuIDsNeeded, .itemIDsNeeded:
            return "Cart does not contain required items"
//        case .cartEmpty:
//            return "Your cart is empty"
        case .storeIdConflict(let isDelivery):
            if isDelivery {
                return "Offer is not valid for the selected location"
            } else {
                return "Offer is not valid for the selected store"
            }
        }
    }
}
