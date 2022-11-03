//
//  OrderListResponseModel.swift
//  Kudu
//
//  Created by Admin on 10/10/22.
//

import Foundation

protocol OrderStatusType {
    var title: String { get }
    var isActiveOrder: Bool { get }
}

enum DeliveryOrderStatus: String, OrderStatusType {
    
    case orderPlaced = "2"
    case inKitchen = "3"
    case readyForDelivery = "4"
    case outForDelivery = "5"
    case delivered = "6"

    var title: String {
        switch self {
        case .orderPlaced:
            return "Order Placed"
        case .inKitchen:
            return "In Kitchen"
        case .readyForDelivery:
            return "Ready for Delivery"
        case .outForDelivery:
            return "Out for Delivery"
        case .delivered:
            return "Delivered"
        }
    }
    
    var isActiveOrder: Bool { self != .delivered }
}

enum CurbsidePickupOrderStatus: String, OrderStatusType {
    
    case orderPlaced = "2"
    case inKitchen = "3"
    case readytoPickup = "4"
    case collected = "6"
    case cancelled = "7"
    
    var title: String {
        switch self {
        case .orderPlaced:
            return "Order Placed"
        case .inKitchen:
            return "In Kitchen"
        case .readytoPickup:
            return "Ready to Pickup"
        case .collected:
            return "Collected"
        case .cancelled:
            return "Cancelled"
        }
    }
    
    var isActiveOrder: Bool { self != .collected && self != .cancelled }
}

struct OrderListResponseModel: Codable {
    let message: String?
    let statusCode: Int?
    let data: OrderListData?
}

struct OrderListData: Codable {
    let data: [OrderListItem]?
    let pageNo: Int?
    let total: Int?
    let totalPage: Int?
    let nextHit: Int?
}

struct OrderDetailResponse: Codable {
    let message: String?
    let statusCode: Int?
    let data: OrderListItem?
}

struct OrderListItem: Codable {
    let _id: String?
    
    let restaurantLocation: RestaurantLocation?
    let servicesAvailable: String?
    
    let items: [CartListObject]?
    
    let totalItemAmount: Double?
    let totalAmount: Double?
    let deliveryCharge: Double?
    
    let paymentType: String?
    let paymentStatus: String?
    
    let orderId: String?
    let created: Int?
    let etaTime: Int?
    let orderStatus: String?
    
    let timeWithStatus: [OrderTimeWithStatus]?
    
    let userAddress: MyAddressListItem?
    
    let scheduleTime: Int?
    
    let discount: Double?
    let vat: Double?
    
    let vehicleDetails: VehicleDetails?
    let isArrived: Bool?
    let arrivedStatus: String?
    
    let rating: RatingModel?
    
    func checkIfOrderDelayed() -> Bool {
        let created = Date(timeIntervalSince1970: Double(created ?? 0)/1000)
        let minutes = created.totalMinutes
        let currentMinutes = Date().totalMinutes
        let timePassed = currentMinutes - minutes
        return timePassed >= etaTime ?? 0
    }
    
    func calculateETA() -> String {
        let created = Date(timeIntervalSince1970: Double(created ?? 0)/1000)
        let minutes = created.totalMinutes
        let currentMinutes = Date().totalMinutes
        let timePassed = currentMinutes - minutes
        if timePassed >= etaTime ?? 0 {
            return "Order Delayed"
        } else {
            let totalEta = etaTime ?? 0
            let createdTSInMS = self.created ?? 0
            let promiseTS = createdTSInMS + (totalEta*60*1000)
            let promiseDate = Date(timeIntervalSince1970: Double(promiseTS/1000))
            return "ETA : \(promiseDate.toString(dateFormat: Date.DateFormat.hmmazzz.rawValue))"
        }
    }
    
    func getServiceType() -> APIEndPoints.ServicesType {
        APIEndPoints.ServicesType(rawValue: self.servicesAvailable ?? "") ?? .delivery
    }
    
    func getScheduledDateTime() -> String? {
        guard let scheduleTime = scheduleTime else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(Double(scheduleTime)/1000.00))
        let string = date.toString(dateFormat: Date.DateFormat.dMMMYYYYatHHmma.rawValue)
        let returnString = "Scheduled for " + string
        return returnString
    }
    
    func getOrderStatus() -> OrderStatusType {
        if self.getServiceType() == .delivery {
            return DeliveryOrderStatus(rawValue: self.orderStatus ?? "") ?? .delivered
        } else {
            return CurbsidePickupOrderStatus(rawValue: self.orderStatus ?? "") ?? .collected
        }
    }
}

struct RatingModel: Codable {
    let rate: Double?
    let description: String?
}

struct OrderTimeWithStatus: Codable {
    let orderStatus: String?
    let time: Int?
}
