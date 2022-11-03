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
        
        static func orderList(pageNo: Int, success: @escaping SuccessCompletionBlock<OrderListResponseModel>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .orderList(pageNo: pageNo), successHandler: success, failureHandler: failure)
        }
        
        static func orderDetails(orderId: String, success: @escaping SuccessCompletionBlock<OrderDetailResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .orderDetails(orderId: orderId), successHandler: success, failureHandler: failure)
        }
        
        static func markArrivedAtStore(orderId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .arrivedAtStore(orderId: orderId), successHandler: success, failureHandler: failure)
        }
        
        static func cancelOrder(orderId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .cancelOrder(orderId: orderId), successHandler: success, failureHandler: failure)
        }
        
        static func rateOrder(req: RatingRequestModel, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .rating(req: req), successHandler: success, failureHandler: failure)
        }
        
        static func reorderItems(orderId: String, success: @escaping SuccessCompletionBlock<EmptyDataResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .reorderItems(orderId: orderId), successHandler: success, failureHandler: failure)
        }
        
        static func validateOrder(req: OrderPlaceRequest, success: @escaping SuccessCompletionBlock<ValidateOrderResponse>, failure: @escaping ErrorFailureCompletionBlock) {
            Api.requestNew(endpoint: .validateOrder(req: req), successHandler: success, failureHandler: failure)
        }
    }
}
