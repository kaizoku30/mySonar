//
//  PaymentTestEndPoints.swift
//  Kudu
//
//  Created by Admin on 28/04/22.
//

import Foundation

class APIEndPoints {
    
    enum AddressLabelType: String {
        case OTHER
        case HOME
        case WORK
        
        var displayText: String {
            switch self {
            case .HOME:
                return "Home"
            case .WORK:
                return "Work"
            default:
                return ""
            }
        }
    }
    
    enum ServicesType: String {
        case curbside
        case delivery
        case pickup
    }
    
    final class PaymentTestEndPoints {
        static func payADollar(cardToken: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .payment(cardToken: cardToken), successHandler: success, failureHandler: failure)
        }
    }
}
