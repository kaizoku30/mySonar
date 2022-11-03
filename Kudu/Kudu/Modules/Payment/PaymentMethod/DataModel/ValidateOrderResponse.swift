//
//  ValidateOrderResponse.swift
//  Kudu
//
//  Created by Admin on 20/10/22.
//

import Foundation

struct ValidateOrderResponse: Codable {
    let statusCode: Int?
    let message: String?
    let data: ValidateOrderData?
    let type: String?
}

struct ValidateOrderData: Codable {
    let orderId: String?
}
