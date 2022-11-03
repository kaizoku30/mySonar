//
//  CartConfigResponseModel.swift
//  Kudu
//
//  Created by Admin on 16/09/22.
//

import Foundation

struct CartConfigResponseModel: Codable {
	let message: String?
	let statusCode: Int?
	let data: CartConfig?
}

struct CartConfig: Codable {
	let vat: Double?
	let deliveryCharges: Double?
	let notificationWaitTime: Int?
	let redeemTimer: Int?
    let vehicleDetails: VehicleDetails?
    let storeDetails: StoreDetail?
    let newNotification: Bool?
}

struct VehicleDetails: Codable {
    let colorCode: String?
    let _id: String?
    let vehicleNumber: String?
    let vehicleName: String?
    let colorName: String?
}
/*
 "colorCode" : "#a1682f",
 "_id" : "6329947c57037cdecfe8a41e",
 "vehicleNumber" : "vsdhjdvchjtytu786356573",
 "vehicleName" : "Desire",
 "colorName" : "sepiaBrown"
 */
