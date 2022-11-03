//
//  AddCardPaymentRequest.swift
//  Kudu
//
//  Created by Admin on 18/10/22.
//

import Foundation

struct AddCardPaymentRequest {
    let orderId: String
    let token: String
    let isSave: Bool
    let isDefault: Bool
    let amount: Double
    let type: CheckoutPaymentType
    let cardHolderName: String?
    
    func getRequest() -> [String: Any] {
        let keyRef = Constants.APIKeys.self
        var params: [String: Any] = [keyRef.orderId.rawValue: orderId,
                keyRef.token.rawValue: token,
                keyRef.isSave.rawValue: isSave,
                keyRef.isDefault.rawValue: isDefault,
                keyRef.amount.rawValue: amount,
                keyRef.type.rawValue: type.rawValue]
        if isSave, let cardHolderName = cardHolderName, cardHolderName.isEmpty == false {
            params[keyRef.cardHolderName.rawValue] = cardHolderName
        }
        return params
    }
}
