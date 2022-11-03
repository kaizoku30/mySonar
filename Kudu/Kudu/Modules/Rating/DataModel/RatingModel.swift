//
//  RatingModel.swift
//  Kudu
//
//  Created by Harpreet Kaur on 2022-10-11.
//

import Foundation

struct RatingRequestModel {
    var orderId: String
    var rate: Double
    var description: String
    
    init() {
        orderId = ""
        rate = 0
        description = ""
    }
    
    func getRequest() -> [String: Any] {
        let key = Constants.APIKeys.self
        let params: [String: Any] = [key.orderId.rawValue: orderId,
                                     key.rate.rawValue: rate,
                                     key.description.rawValue: description]
        return params
    }
}
