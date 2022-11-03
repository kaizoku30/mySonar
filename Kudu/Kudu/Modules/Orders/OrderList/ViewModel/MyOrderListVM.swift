//
//  MyOrderListVM.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import Foundation

class MyOrderListVM {
    private var pageNo: Int = 1
    private var total: Int = 0
    private var orders: [OrderListItem] = [] {
        didSet {
            activeOrders = orders.filter({ $0.getOrderStatus().isActiveOrder })
            previousOrders = orders.filter({ !$0.getOrderStatus().isActiveOrder })
        }
    }
    private var activeOrders: [OrderListItem] = []
    private var previousOrders: [OrderListItem] = []
    private var reorderId: String?
    
    var getPageNo: Int { pageNo }
    var getTotal: Int { total }
    var getOrders: [OrderListItem] { orders }
    var getActiveOrders: [OrderListItem] { activeOrders }
    var getPreviousOrders: [OrderListItem] { previousOrders }
    
    func setupReorder(_ id: String) {
        reorderId = id
    }
    
    func getOrderList(pageNo: Int, fetched: @escaping ((Result<Bool, Error>) -> Void)) {
        APIEndPoints.OrderEndPoints.orderList(pageNo: pageNo, success: { [weak self] in
            guard let strongSelf = self, let pageNoInc = $0.data?.pageNo, let totalInc = $0.data?.total else { return }
            strongSelf.pageNo = pageNoInc
            strongSelf.total = totalInc
            if pageNoInc == 1 {
                strongSelf.orders = $0.data?.data ?? []
            } else {
                strongSelf.orders.append(contentsOf: $0.data?.data ?? [])
            }
            fetched(.success(true))
        }, failure: { [weak self] in
            self?.pageNo = 1
            self?.total = 0
            self?.orders = []
            fetched(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func reorderItems(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let reorderId = reorderId else {
            completion(.failure(NSError(localizedDescription: "Could not find order id")))
            return }
        APIEndPoints.OrderEndPoints.reorderItems(orderId: reorderId, success: { _ in
            completion(.success(true))
        }, failure: {
            completion(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func markArrived(forOrderId orderId: String, completed: @escaping (Result<OrderListItem, Error>) -> Void) {
        APIEndPoints.OrderEndPoints.markArrivedAtStore(orderId: orderId, success: { _ in
            APIEndPoints.OrderEndPoints.orderDetails(orderId: orderId, success: { (updatedData) in
                guard let updatedDetails = updatedData.data else {
                    completed(.failure(NSError(localizedDescription: "Some error occurred, please try again later.")))
                    return
                }
                completed(.success(updatedDetails))
            }, failure: {
                completed(.failure(NSError(localizedDescription: $0.msg)))
            })
        }, failure: {
            completed(.failure(NSError(localizedDescription: $0.msg)))
        })
    }
    
    func updateSpecificActiveOrder(index: Int, updatedObj: OrderListItem) {
        if index < activeOrders.count {
            activeOrders[index] = updatedObj
        }
    }
}
