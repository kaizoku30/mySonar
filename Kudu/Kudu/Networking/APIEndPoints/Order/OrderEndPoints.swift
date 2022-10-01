//
//  OrderEndPoints.swift
//  Kudu
//
//  Created by Admin on 30/09/22.
//

import Foundation

extension APIEndPoints {
    final class OrderEndPoints {
        static func placeOrder(req: OrderPlaceRequest, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .placeOrder(req: req), successHandler: success, failureHandler: failure)
        }
    }
}
