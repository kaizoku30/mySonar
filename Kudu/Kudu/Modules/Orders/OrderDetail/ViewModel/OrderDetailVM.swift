//
//  OrderDetailVM.swift
//  Kudu
//
//  Created by Admin on 11/10/22.
//

import UIKit

class OrderDetailVM {
    private var orderId: String!
    private var orderDetail: OrderListItem!
    var getOrderDetail: OrderListItem {
        orderDetail
    }
    func configure(orderId: String) {
        self.orderId = orderId
    }
    
    func fetchOrderDetail(completion: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.OrderEndPoints.orderDetails(orderId: orderId, success: { [weak self] (response) in
            if response.data.isNil {
                completion(.failure(NSError(localizedDescription: "Some error occurred, please try again later.")))
                return }
            self?.orderDetail = response.data
            NotificationCenter.postNotificationForObservers(.updateOrderObject, object: ["orderListItem": response.data!])
            completion(.success(true))
        }, failure: {
            completion(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func markArrival(completion: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.OrderEndPoints.markArrivedAtStore(orderId: orderId, success: { [weak self] _ in
            self?.fetchOrderDetail(completion: completion)
        }, failure: {
            completion(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func cancelOrder(completion: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.OrderEndPoints.cancelOrder(orderId: orderId, success: { [weak self] _ in
            self?.fetchOrderDetail(completion: completion)
        }, failure: {
            completion(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func reorderItems(completion: @escaping (Result<Bool, Error>) -> Void) {
        APIEndPoints.OrderEndPoints.reorderItems(orderId: orderId, success: { _ in
            completion(.success(true))
        }, failure: {
            completion(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
}
